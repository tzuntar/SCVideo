//
//  UserProfileViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import UIKit

class UserProfileViewController: UIViewController {

    var currentUser: User?
    var userPosts: [Post]?
    private var isFriend: Bool?
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userSchool: UILabel!
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var userBioPlaceholder: UILabel!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    @IBOutlet weak var addFriendButton: UIButton!

    private var friendsLogic: FriendsLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(UINib(nibName: "PostCell", bundle: nil),
                                     forCellWithReuseIdentifier: "PostCell")

        userBio.layer.borderWidth = 2
        userBio.layer.borderColor = UIColor(named: "DescriptionTextLabel")?.cgColor
        userBio.layer.cornerRadius = 8
        userPhoto.layer.cornerRadius = userPhoto.layer.frame.height / 2

        friendsLogic = FriendsLogic(delegatingActionsTo: self)
        if let user = currentUser {
            userName.text = user.full_name
            userUsername.text = "@\(user.username)"
            if let bio = currentUser!.bio {
                userBio.text = bio
                userBioPlaceholder.isHidden = true
            }
            
            if let photo = user.photo_uri {
                userPhoto.loadFrom(URLAddress: "\(APIURL)/images/profile/\(photo)")
            }

            if (user.id_user != AuthManager.shared.session!.user.id_user) {
                friendsLogic?.checkFriendship(for: user)
            } else {
                addFriendButton.isHidden = true
            }
            fetchUserPosts()
        }
    }

    @IBAction func addFriendPressed(_ sender: UIButton) {
        guard let user = currentUser else { return }
        if isFriend == true {
            friendsLogic?.removeFriend(user: user)
        } else {
            friendsLogic?.addFriend(user: user)
        }
    }
    
    private func toggleAddFriendButton(userIsFriend: Bool) {
        let imageName = userIsFriend ? "RemoveFriendButton" : "AddFriendButton"
        addFriendButton.setImage(UIImage(named: imageName), for: .normal)
    }
    
    private func fetchUserPosts() {
        PostLoaderLogic.loadPostsForUser(currentUser!) { (posts: [Post]?) in
            self.userPosts = posts
            self.postsCollectionView.reloadData()
        }
    }
    
}

extension UserProfileViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = userPosts else { return 0 }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        guard let posts = userPosts else { return cell }
        cell.loadPost(posts[indexPath.row])
        return cell
    }

}

extension UserProfileViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftAndRightPaddings: CGFloat = 20.0
        let numberOfItemsPerRow: CGFloat = 2.0
        let width = (collectionView.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }

}

// MARK: - Friend Actions Delegate
extension UserProfileViewController : FriendProfileDelegate {

    func didCheckFriendship(_ isFriend: Bool) {
        self.isFriend = isFriend
        toggleAddFriendButton(userIsFriend: isFriend)
    }

    func didAddFriend(_ friend: User) {
        isFriend = true
        toggleAddFriendButton(userIsFriend: true)
    }

    func didRemoveFriend(_ friend: User) {
        isFriend = false
        toggleAddFriendButton(userIsFriend: false)
    }
    
    func didFriendActionFailWithError(_ error: Error) {
        WarningAlert().showWarning(withTitle: "Napaka",
                                   withDescription: "Prijatelja ni bilo mogoče dodati, prosimo, poskusite kasneje")
        print(error)
    }
    
}
