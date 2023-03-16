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
