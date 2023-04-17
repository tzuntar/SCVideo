//
//  FeedVideoNode.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/17/23.
//

import Foundation
import AsyncDisplayKit

class FeedVideoNode: ASVideoNode {

    override func didExitDisplayState() {
        super.didExitDisplayState()
        if !isVisible { // attempts to fix autoplay pausing problems
            player?.pause()
        }
    }

}