//
//  FriendsViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/25/22.
//

import UIKit

class FriendsViewController: UIViewController {
    
    var currentSession: UserSession?
    var friends: [User]?
    var friendsLogic: FriendsLogic?
    var selectedFriend: User?

    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.dataSource = self
        friendsTableView.register(UINib(nibName: "UserCell", bundle: nil),
                                  forCellReuseIdentifier: "UserCell")

        if let safeSession = currentSession {
            friendsLogic = FriendsLogic(session: safeSession, withDelegate: self)
            friendsLogic!.retrieveFriends()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFriendAccount" {
            guard let friendProfileVC = segue.destination as? UserProfileViewController,
                  let friend = selectedFriend else { return }
            friendProfileVC.currentSession = currentSession
            friendProfileVC.currentUser = friend
        }
    }

}   

// MARK: - Friends Delegate Division

extension FriendsViewController: FriendListDelegate {
    
    func didFetchFriends(_ friends: [User]) {
        self.friends = friends
        friendsTableView.reloadData()
    }
    
    func didFriendActionFailWithError(_ error: Error) {
        WarningAlert().showWarning(withTitle: "Napaka",
                                   withDescription: "Seznama prijateljev ni bilo mogoče naložiti")
        print(error)
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
    }

}

// MARK: - Table View Data Handling

extension FriendsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let friends = self.friends else { return 0 }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell
        guard let friends = self.friends else { return cell }
        cell.loadData(forUser: friends[indexPath.row])
        return cell
    }
    
}
