//
//  PostDetails.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit

class PostDetails: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var hashtagsLabel: UILabel!
    
    private let _CONTENT_XIB_NAME = "PostDetails"
    private var _post: Post?
    
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
        usernameLabel.text = "@\(post.user.username)"
        captionLabel.text = post.title ?? "No caption"
        descriptionLabel.text = post.description ?? "No description"
    }

}
