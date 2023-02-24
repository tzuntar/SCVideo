//
//  UserCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import UIKit

class UserCell: UITableViewCell {
    
    var currentUser: User?

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileImage.layer.cornerRadius = userProfileImage.layer.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(forUser user: User) {
        self.currentUser = user
        usernameButton.setTitle(user.full_name, for: .normal)
        if let avatarURL = user.photo_uri {
            userProfileImage.loadFrom(URLAddress: avatarURL)
        }
    }
    
    @IBAction func userButtonPressed(_ sender: UIButton) {
        if let parentVC = parentViewController as? FriendsViewController,
           let friend = currentUser {
            parentVC.selectedFriend = friend
            parentVC.performSegue(withIdentifier: "showFriendAccount", sender: parentVC)
        }
    }
    
}
