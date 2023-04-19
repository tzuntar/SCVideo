//
//  FeedVideoNode.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/17/23.
//

import Foundation
import AsyncDisplayKit

class FeedVideoNode: ASVideoNode {
    
    override func didLoad() {
        super.didLoad()
        delegate = self
    }

    override func didExitDisplayState() {
        super.didExitDisplayState()
        if !isVisible { // attempts to fix autoplay pausing problems
            player?.pause()
        }
    }

}

extension FeedVideoNode: ASVideoNodeDelegate {
    
    func didTap(_ videoNode: ASVideoNode) {
        videoNode.muted = false//!videoNode.muted
    }

}
