//
//  PostControlsView.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit

class PostControlsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var likeButtonIcon: UIImageView!
    //@IBOutlet weak var likeCountLabel: UILabel!
    //@IBOutlet weak var commentCountLabel: UILabel!

    private let _CONTENT_XIB_NAME = "PostControls"
    private var delegate: PostNodeActionDelegate?
    private var currentPost: Post?
    private let feedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed(_CONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    public func setPost(post: Post) {
        currentPost = post
        if post.user!.id_user == AuthManager.shared.session!.user.id_user {
            //likeCountLabel.isHidden = false
            //likeCountLabel.text = like_count
        }
        likeButtonIcon.image = UIImage(named: (post.is_liked == 0) ? "Like" : "Liked")
    }
    
    public func setDelegate(delegate: PostNodeActionDelegate) {
        self.delegate = delegate
    }

}

// MARK: - Post Actions
extension PostControlsView {

    @IBAction func likePost(_ sender: UIButton) {
        feedbackGenerator.impactOccurred()
        guard let safePost = currentPost else { return }
        let isLiked = !(safePost.is_liked == 1)
        likeButtonIcon.image = UIImage(named: (isLiked ? "Liked" : "Like"))
        delegate?.didTapLikePost(safePost, isLiked: isLiked)
    }

    @IBAction func commentPost(_ sender: UIButton) {
        feedbackGenerator.impactOccurred()
        guard let safePost = currentPost else { return }
        delegate?.didTapCommentPost(safePost)
    }

    @IBAction func sharePost(_ sender: UIButton) {
        feedbackGenerator.impactOccurred()
        guard let safePost = currentPost else { return }
        delegate?.didTapSharePost(safePost)
    }
    
}
