//
//  FriendsViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/25/22.
//

import UIKit

class FriendsViewController: UIViewController {

    var friends: [User]?
    var strangers: [User]?

    var allFriends: [User]? // used when searching
    var allStrangers: [User]?

    var friendsLogic: FriendsLogic?
    var selectedUser: User?

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        friendsTableView.register(UINib(nibName: "UserCell", bundle: nil),
                                  forCellReuseIdentifier: "UserCell")
        friendsTableView.dataSource = self
        friendsLogic = FriendsLogic(delegatingActionsTo: self)
        searchField.delegate = self

        // the pull-to-refresh thingy
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshFriendsList), for: .valueChanged)
        friendsTableView.refreshControl = refreshControl

        DispatchQueue.global(qos: .background).async {
            self.friendsLogic!.retrieveFriends()
            self.friendsLogic!.retrieveStrangers()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendAccount" {
            guard let userProfileVC = segue.destination as? UserProfileViewController,
                  let user = selectedUser else { return }
            userProfileVC.currentUser = user
        }
    }

    @objc func refreshFriendsList() {
        DispatchQueue.global(qos: .background).async {
            self.friendsLogic!.retrieveFriends()
            self.friendsLogic!.retrieveStrangers()
            DispatchQueue.main.async {
                self.friendsTableView.refreshControl?.endRefreshing()
            }
        }
    }

}   

// MARK: - Friends Delegate Division

extension FriendsViewController: FriendListDelegate {
    
    func didFetchFriends(_ friends: [User]) {
        self.friends = friends
        allFriends = friends
        DispatchQueue.main.async {
            self.friendsTableView.reloadData()
        }
    }

    func didFetchStrangers(_ strangers: [User]) {
        self.strangers = strangers
        allStrangers = strangers
        DispatchQueue.main.async {
            self.friendsTableView.reloadData()
        }
    }
    
    func didFriendActionFailWithError(_ error: Error) {
        print(error)
        DispatchQueue.main.async {
            WarningAlert().showWarning(withTitle: "Napaka",
                                       withDescription: "Seznama prijateljev ni bilo mogoče naložiti")
        }
    }

}

// MARK: - Table View Data Handling

extension FriendsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        (friends?.count ?? 0) + (strangers?.count ?? 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell

        if friends != nil && friends?.count ?? 0 > 0 {
            if indexPath.row < friends!.count {
                cell.loadData(forUser: friends![indexPath.row])
                if indexPath.row == friends!.count - 1 { // add a separator between friends and strangers
                    let borderBottom = CALayer()
                    borderBottom.backgroundColor = UIColor(named: "DescriptionTextLabel")?.cgColor
                    borderBottom.opacity = 0.5
                    borderBottom.frame = CGRect(x: 15,
                                                y: cell.frame.height - 20,
                                                width: tableView.frame.width - 30,
                                                height: 2)
                    cell.layer.addSublayer(borderBottom)
                }
                return cell
            }
        }

        if strangers != nil && strangers?.count ?? 0 > 0 {
            let index = indexPath.row - (friends?.count ?? 0)
            cell.loadData(forUser: strangers![index])
        }

        return cell
    }

}

// MARK: - Search Field Delegate

extension FriendsViewController: UITextFieldDelegate {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchTerm: String? = (textField.text as? NSString)?.replacingCharacters(in: range, with: string)
        guard searchTerm != nil && searchTerm != "" else { return true }
        friends = allFriends?.filter { $0.username.lowercased().contains(searchTerm!.lowercased()) }
        strangers = allStrangers?.filter { $0.username.lowercased().contains(searchTerm!.lowercased()) }
        friendsTableView.reloadData()
        return true
    }

}
