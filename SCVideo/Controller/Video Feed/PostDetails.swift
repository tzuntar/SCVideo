//
//  PostDetails.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit

class PostDetails: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hashtagsLabel: UILabel!
    
    private let _CONTENT_XIB_NAME = "PostDetails"
    private var currentPost: Post?
    private var delegate: PostNodeActionDelegate?
    
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
        usernameButton.setTitle("@\(post.user!.username)", for: .normal)
        captionLabel.text = post.title ?? "No caption"
        descriptionLabel.text = post.description ?? "No description"
    }
    
    public func setDelegate(delegate: PostNodeActionDelegate) {
        self.delegate = delegate
    }
}

// MARK: - Post Actions
extension PostDetails {
    @IBAction func usernamePressed(_ sender: UIButton) {
        delegate?.didTapUserProfile(currentPost!)
    }
}
