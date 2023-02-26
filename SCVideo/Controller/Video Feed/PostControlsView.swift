//
//  PostControlsView.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import UIKit

class PostControlsView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    private let _CONTENT_XIB_NAME = "PostControls"
    
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

// MARK: - Custom Sizing / Scaling
extension UIView {
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading,
                           relatedBy: .equal, toItem: container,
                           attribute: .leading, multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing,
                           relatedBy: .equal, toItem: container,
                           attribute: .trailing, multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top,
                           relatedBy: .equal, toItem: container,
                           attribute: .top, multiplier: 1.0,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom,
                           relatedBy: .equal, toItem: container,
                           attribute: .bottom, multiplier: 1.0,
                           constant: 0).isActive = true
    }
}
