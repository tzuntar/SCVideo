//
//  PostProtocols.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/8/23.
//

import Foundation

protocol PostNodeActionDelegate {
    func didTapLikePost(_ post: Post, isLiked: Bool)
    func didTapCommentPost(_ post: Post)
    func didTapSharePost(_ post: Post)
    
    func didTapUserProfile(_ post: Post)
}

extension UIView {
    /**
     Enables using constraint-based views in ASD nodes
     */
    func fixInView(_ container: UIView!) -> Void {
        translatesAutoresizingMaskIntoConstraints = false
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
