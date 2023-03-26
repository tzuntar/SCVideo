//
//  MyAccountViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import UIKit

class MyAccountViewController: UIViewController {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var schoolLabel: UILabel!
    @IBOutlet weak var bioTextBox: UITextView!
    @IBOutlet weak var postsCollectionView: UICollectionView!
    
    private var currentUser: User?
    private var userPosts: [Post]?

    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = AuthManager.shared.session!.user
        
        profilePic.layer.cornerRadius = profilePic.layer.frame.height / 2
        
        nameLabel.text = currentUser!.full_name
        usernameLabel.text = "@\(currentUser!.username)"
        bioTextBox.text = currentUser!.bio
        if let avatarURL = currentUser!.photo_uri {
            profilePic.loadFrom(URLAddress: "\(APIURL)/images/profile/\(avatarURL)")
        }
        fetchUserPosts()
    }

    @IBAction func selectProfilePicPressed(_ sender: UIButton) {
    }
    
    private func fetchUserPosts() {
        PostLoaderLogic.loadPostsForUser(currentUser!) { (posts: [Post]?) in
            self.userPosts = posts
            self.postsCollectionView.reloadData()
        }
    }
}

extension MyAccountViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let posts = userPosts else { return 0 }
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCell", for: indexPath) as! PostCell
        guard let posts = userPosts else { return cell }
        cell.loadPost(posts[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let leftAndRightPaddings: CGFloat = 45.0
        let numberOfItemsPerRow: CGFloat = 4.0
        let width = (collectionView.frame.width - leftAndRightPaddings) / numberOfItemsPerRow
        return CGSize(width: width, height: width)
    }
}
