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
                #if ENABLE_FRIENDS_LIST_SEPARATOR
                    if indexPath.row == friends!.count - 1 {    // add a separator cell after the last friend cell
                        let separatorCell = SeparatorCell(style: .default, reuseIdentifier: "SeparatorCell")
                        tableView.insertSubview(separatorCell, at: indexPath.row)
                    }
                #endif
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
        var searchTerm = textField.text ?? ""
        if let stringRange = Range(range, in: searchTerm) {
            searchTerm = searchTerm.replacingCharacters(in: stringRange, with: string)
        }

        if searchTerm.isEmpty {
            friends = allFriends
            strangers = allStrangers
        } else {
            friends = allFriends?.filter { $0.username.lowercased().contains(searchTerm.lowercased()) }
            strangers = allStrangers?.filter { $0.username.lowercased().contains(searchTerm.lowercased()) }
        }

        friendsTableView.reloadData()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let searchTerm = textField.text?.lowercased()
        if searchTerm?.isEmpty == false {
            friends = allFriends?.filter { $0.username.lowercased().contains(searchTerm!) }
            strangers = allStrangers?.filter { $0.username.lowercased().contains(searchTerm!) }
        } else {
            friends = allFriends
            strangers = allStrangers
        }
        friendsTableView.reloadData()
        return true
    }

}
