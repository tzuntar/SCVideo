//
//  PostCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import UIKit
import AVFoundation

class PostCell: UITableViewCell {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postImageContainer: UIView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    private var currentPost: Post?
    
    // only applicable to video posts
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        /*postView.layer.borderWidth = 3
        postView.layer.borderColor = UIColor.white.cgColor
        postView.layer.cornerRadius = 20
        postImage.layer.cornerRadius = 20
        postImageContainer.layer.borderWidth = 3
        postImageContainer.layer.borderColor = UIColor.white.cgColor
        postImageContainer.layer.cornerRadius = 20*/
        userProfileImage.layer.cornerRadius = userProfileImage.layer.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let post = currentPost else { return }
        let logic = PostActionsLogic(delegatingActionsTo: self)
        logic.toggleLike(post)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func commentButtonPressed(_ sender: UIButton) {
        /*if let parentVC = self.parentViewController as? HomeViewController {
            parentVC.selectedPost = currentPost
            parentVC.performSegue(withIdentifier: "showPostComments", sender: parentVC)
        }*/
    }
    
    @IBAction func userButtonPressed(_ sender: Any) {
        /*guard let post = currentPost else { return }
        if let parentVC = self.parentViewController as? HomeViewController {
            parentVC.selectedPostUser = post.user
            parentVC.performSegue(withIdentifier: "showPostAccount", sender: parentVC)
        }*/
    }
    
    @objc func playButtonPressed(_ sender: UIImageView) {
        guard let post = currentPost else { return }
        let frame = self.postImage.frame
        
        player = AVPlayer(url: URL(string: post.content_uri)!)
        playerLayer = AVPlayerLayer(player: player)
        let audioSession = AVAudioSession.sharedInstance()
        playerLayer!.frame = frame
        playerLayer!.videoGravity = .resizeAspectFill
        postImageContainer.layer.addSublayer(playerLayer!)
        player?.volume = 1
        player?.play()
        player?.actionAtItemEnd = .none
    }
    
    func loadData(forPost post: Post, asSession session: UserSession) {
        self.currentPost = post
        
        usernameButton.setTitle(post.user.full_name, for: .normal)
        contentLabel.text = post.description
        if post.type == PostType.photo.rawValue {
            postImage.loadFrom(URLAddress: post.content_uri)
        } else if post.type == PostType.video.rawValue {
            DispatchQueue.global(qos: .background).async {
                let loader = PostLoaderLogic(delegate: self)
                loader.loadVideoPostThumbnail(forPost: post)
            }
        }
        if let avatarURL = post.user.photo_uri {
            userProfileImage.loadFrom(URLAddress: "\(APIURL)/images/profile/\(avatarURL)")
        }
        refreshPostLikeStatus(isPostLiked: post.is_liked == 1)
    }
    
    private func refreshPostLikeStatus(isPostLiked liked: Bool) {
        likeButton.setImage(UIImage(named: liked ? "Liked" : "Like"),
                            for: .normal)
    }
}

// MARK: - Post Loading

extension PostCell: PostLoaderDelegate {
    
    func didLoadVideoThumbnail(_ image: CGImage) {
        DispatchQueue.main.async {
            self.postImage.image = UIImage(cgImage: image)
            let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.playButtonPressed))
            self.postImage.addGestureRecognizer(tap)
            self.postImage.isUserInteractionEnabled = true
        }
    }
    
    func didLoadingFailWithError(_ error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.postImage.image = UIImage(named: "No File")
        }
    }
    
}

// MARK: - Post Action Delegates

extension PostCell: PostActionsDelegate {
    
    func didLikePost(_ post: Post) {
        self.currentPost = post
        refreshPostLikeStatus(isPostLiked: true)
    }
    
    func didUnlikePost(_ post: Post) {
        self.currentPost = post
        refreshPostLikeStatus(isPostLiked: false)
    }
    
    func didActionFailWithError(_ error: Error) {
        WarningAlert().showWarning(withTitle: "Napaka",
                                   withDescription: error.localizedDescription)
    }
    
}
