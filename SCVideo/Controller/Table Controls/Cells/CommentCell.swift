//
//  CommentCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/28/22.
//

import UIKit

class CommentCell: UITableViewCell {
    
    var currentUser: User?

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfileImage.layer.cornerRadius = userProfileImage.layer.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadComment(_ comment: Comment) {
        self.currentUser = comment.user
        usernameButton.setTitle(comment.user.full_name, for: .normal)
        if let avatarURL = comment.user.photo_uri {
            userProfileImage.loadFrom(URLAddress: "\(APIURL)/images/profile/\(avatarURL)")
        }
        contentLabel.text = comment.content
    }
    
    @IBAction func usernameButtonPressed(_ sender: UIButton) {
        if let parentVC = parentViewController as? CommentsViewController,
           let user = currentUser {
            parentVC.selectedCommenter = user
            parentVC.performSegue(withIdentifier: "showCommenterAccount", sender: parentVC)
        }
    }
}
