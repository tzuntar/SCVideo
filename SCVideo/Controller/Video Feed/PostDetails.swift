//
//  PostDetails.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit

class PostDetails: UIView {

    @IBOutlet var contentView: UIView!

    private let _CONTENT_XIB_NAME = "PostDetails"
    
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

}
