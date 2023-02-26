//
//  PostNode.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/26/23.
//

import Foundation
import AsyncDisplayKit

class PostNode: ASCellNode {
    var post: Post
    var thumbnailNode: ASNetworkImageNode   // the thumbnail before a video starts playing
    var videoNode: ASVideoNode
    var gradientNode: GradientNode  // used to provide better contrast for the controls
    
    init(with post: Post) {
        self.post = post
        thumbnailNode = ASNetworkImageNode()
        videoNode = ASVideoNode()
        gradientNode = GradientNode()
        super.init()
        
        //thumbnailNode.url = post.thumbnail_url
        thumbnailNode.contentMode = .scaleAspectFill
        
        // ASD recommends enabling layer-backing in any custom node
        // that doesn’t need touch handling for better performance
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
        
        //videoNode.url = post.thumbnail_url
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = false
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue

        // set the asset on the main thread since the nodes aren't on it
        DispatchQueue.main.async {
            self.videoNode.asset = AVAsset(url: URL(string: post.content_uri!)!) // null handling?
        }
        
        addSubnode(videoNode)
        addSubnode(gradientNode)
        
        // all UIView calls _must_ be done on the main thread
        DispatchQueue.main.async {
            let postControlsView = PostControlsView()
            postControlsView.frame = CGRect(origin: CGPoint(x: 300, y: 280),
                                            size: CGSize(width: 83, height: 320))
            self.view.addSubview(postControlsView)
            
            let postDetailsView = PostDetails()
            postDetailsView.frame = CGRect(origin: CGPoint(x: 0, y: 600),
                                           size: CGSize(width: 414, height: 120))
            self.view.addSubview(postDetailsView)
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratio = UIScreen.main.bounds.height / UIScreen.main.bounds.width
        // lay out a component at a fixed aspect ratio which can scale
        let ratioSpec = ASRatioLayoutSpec(ratio: ratio, child: videoNode)
        // lay out the child with the gradient node stretched on top of it
        let gradientOverlaySpec = ASOverlayLayoutSpec(child: ratioSpec, overlay: gradientNode)
        return gradientOverlaySpec
    }

}
