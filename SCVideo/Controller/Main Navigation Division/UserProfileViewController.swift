//
//  UserProfileViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import UIKit

class UserProfileViewController: UIViewController {

    var currentSession: UserSession?
    var currentUser: User?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userTown: UILabel!
    @IBOutlet weak var userOccupation: UILabel!
    @IBOutlet weak var userEducation: UILabel!
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var addUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userBio.layer.borderWidth = 3
        userBio.layer.borderColor = UIColor.white.cgColor
        userBio.layer.cornerRadius = 8
        userPhoto.layer.cornerRadius = userPhoto.layer.frame.height / 2

        if let user = currentUser {
            userName.text = user.full_name
            userTown.text = user.town?.name
            userOccupation.text = user.occupation
            userEducation.text = user.education
            userBio.text = user.bio
            
            if let photo = user.photo_uri {
                userPhoto.loadFrom(URLAddress: "\(APIURL)/images/profile/\(photo)")
            }
            
            toggleAddFriendButton(userIsFriend: false)  // ToDo: this
        }
    }
    
    @IBAction func addFriendPressed(_ sender: UIButton) {
        guard let session = currentSession,
              let user = currentUser else { return }
        let logic = FriendsLogic(session: session, withDelegate: self)
        logic.addFriend(user: user)
    }
    
    private func toggleAddFriendButton(userIsFriend: Bool) {
        addUserButton.setTitle(userIsFriend ? "Odstrani prijatelja" : "Dodaj prijatelja", for: .normal)
    }
    
}

// MARK: - Friend Actions Delegate

extension UserProfileViewController : AddFriendDelegate {
    
    func didAddSucceed(_ friend: User) {
        // user.is_friend = true
        toggleAddFriendButton(userIsFriend: true)
    }
    
    func didFriendActionFailWithError(_ error: Error) {
        WarningAlert().showWarning(withTitle: "Napaka",
                                   withDescription: "Prijatelja ni bilo mogoče dodati, prosimo, poskusite kasneje")
        print(error)
    }
    
}
