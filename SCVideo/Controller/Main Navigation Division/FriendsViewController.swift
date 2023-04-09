//
//  FriendsViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/25/22.
//

import UIKit

class FriendsViewController: UIViewController {

    var friends: [User]?
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
