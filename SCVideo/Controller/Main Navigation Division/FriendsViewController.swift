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
    var friendsLogic: FriendsLogic?
    var selectedUser: User?

    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.register(UINib(nibName: "UserCell", bundle: nil),
                                  forCellReuseIdentifier: "UserCell")
        friendsTableView.dataSource = self
        friendsLogic = FriendsLogic(delegatingActionsTo: self)
        DispatchQueue.global(qos: .background).async {
            self.friendsLogic!.retrieveFriends()
            self.friendsLogic!.retrieveStrangers()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnotherUsersProfile" {
            guard let userProfileVC = segue.destination as? UserProfileViewController,
                  let user = selectedUser else { return }
            userProfileVC.currentUser = user
        }
    }

}   

// MARK: - Friends Delegate Division

extension FriendsViewController: FriendListDelegate {
    
    func didFetchFriends(_ friends: [User]) {
        self.friends = friends
        DispatchQueue.main.async {
            self.friendsTableView.reloadData()
        }
    }

    func didFetchStrangers(_ strangers: [User]) {
        self.strangers = strangers
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

        if let friends = friends {
            if indexPath.row < friends.count {
                cell.loadData(forUser: friends[indexPath.row])
                return cell
            } else {    // add a separator to the end of the friends list
                let separatorView = UIView(frame: CGRect(x: 0,
                                                         y: cell.contentView.frame.size.height - 1,
                                                         width: cell.contentView.frame.size.width,
                                                         height: 1))
                separatorView.backgroundColor = UIColor(named: "DescriptionTextLabel")
                cell.contentView.addSubview(separatorView)
                return cell
            }
        }

        if let strangers = strangers {
            let index = indexPath.row - (friends?.count ?? 0)
            cell.loadData(forUser: strangers[index])
        }

        return cell
/*
//        guard let friends = friends else { return cell }
        if indexPath.row < (friends?.count ?? 0) {
            cell.loadData(forUser: friends![indexPath.row])
        } else {
            guard let strangers = strangers else { return cell }
            if indexPath.row == (friends?.count ?? 0) { // add a separator
                let separatorView = UIView(frame: CGRect(x: 0,
                                                         y: cell.contentView.frame.size.height - 1,
                                                         width: cell.contentView.frame.size.width,
                                                         height: 1))
                separatorView.backgroundColor = UIColor(named: "DescriptionTextLabel")
                cell.contentView.addSubview(separatorView)
            }
            cell.loadData(forUser: strangers[indexPath.row])
        }
        return cell*/
    }

}
