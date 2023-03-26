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
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userUsername: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userSchool: UILabel!
    @IBOutlet weak var userBio: UITextView!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postsCollectionView.delegate = self
        postsCollectionView.dataSource = self
        postsCollectionView.register(UINib(nibName: "PostCell", bundle: nil),
                                     forCellWithReuseIdentifier: "PostCell")

        userBio.layer.borderWidth = 3
        userBio.layer.borderColor = UIColor.white.cgColor
        userBio.layer.cornerRadius = 8
        userPhoto.layer.cornerRadius = userPhoto.layer.frame.height / 2

        if let user = currentUser {
            userName.text = user.full_name
            userUsername.text = "@\(user.username)"
            userBio.text = user.bio
            
            if let photo = user.photo_uri {
                userPhoto.loadFrom(URLAddress: "\(APIURL)/images/profile/\(photo)")
            }
            
            toggleAddFriendButton(userIsFriend: false)  // ToDo: this
            fetchUserPosts()
        }
    }

    @IBAction func addFriendPressed(_ sender: UIButton) {
        guard let user = currentUser else { return }
        let logic = FriendsLogic(delegatingActionsTo: self)
        /*if (userIsFriend) {
            logic.removeFriend(user)
        } else {*/
            logic.addFriend(user: user)
        //}
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
        let leftAndRightPaddings: CGFloat = 45.0
        let numberOfItemsPerRow: CGFloat = 4.0
        let width = (collectionView.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
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
