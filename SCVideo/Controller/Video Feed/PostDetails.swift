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
    private var _post: Post?
    private var _delegate: PostNodeActionDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialize()
    }
    
    private func initialize() {
        Bundle.main.loadNibNamed(_CONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
    }
    
    public func setPost(post: Post) {
        self._post = post
        usernameButton.setTitle("@\(post.user.username)", for: .normal)
        captionLabel.text = post.title ?? "No caption"
        descriptionLabel.text = post.description ?? "No description"
    }
    
    public func setDelegate(delegate: PostNodeActionDelegate) {
        self._delegate = delegate
    }
}

// MARK: - Post Actions
extension PostDetails {
    @IBAction func usernamePressed(_ sender: UIButton) {
        _delegate?.didTapUserProfile(_post!)
    }
}
