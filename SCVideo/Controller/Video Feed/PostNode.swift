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
    private var nodeActionsDelegate: PostNodeActionDelegate
    var thumbnailNode: ASNetworkImageNode   // the thumbnail before a video starts playing
    var videoNode: ASVideoNode
    var gradientNode: GradientNode  // used to provide better contrast for the controls

    init(with post: Post, delegatingActionsTo nodeActionsDelegate: PostNodeActionDelegate) {
        self.post = post
        self.nodeActionsDelegate = nodeActionsDelegate
        thumbnailNode = ASNetworkImageNode()
        videoNode = ASVideoNode()
        gradientNode = GradientNode()
        super.init()

        PostLoaderLogic.fetchVideoThumbnail(forPost: post) { (image: CGImage?, error: Error?) in
            guard let img = image else {
                if let e = error {
                    print("Fetching thumbnail for post \(post.id_post) failed: \(e.localizedDescription)")
                }
                return
            }
            self.thumbnailNode.image = UIImage(cgImage: img)
        }
        thumbnailNode.contentMode = .scaleAspectFill
        
        // ASD recommends enabling layer-backing in any custom node
        // that doesn’t need touch handling for better performance
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
        
        //videoNode.url = post.thumbnail_url
        videoNode.shouldAutoplay = false
        videoNode.shouldAutorepeat = false
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue

        addSubnode(videoNode)
        addSubnode(gradientNode)
    }
    
    override func didLoad() {
        super.didLoad()
        // set the asset on the main thread since the nodes aren't on it
        self.videoNode.assetURL = URL(string: "\(APIURL)/posts/videos/\(post.content_uri)")!

        // all UIView calls _must_ be done on the main thread
        let postControlsView = PostControlsView()
        postControlsView.frame = CGRect(origin: CGPoint(x: 300, y: 280),
                                        size: CGSize(width: 83, height: 320))
        postControlsView.setPost(post: post)
        postControlsView.setDelegate(delegate: nodeActionsDelegate)
        self.view.addSubview(postControlsView)

        let postDetailsView = PostDetails()
        postDetailsView.frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 170),
                                       size: CGSize(width: 414, height: 141))
        postDetailsView.setPost(post: post)
        postDetailsView.setDelegate(delegate: nodeActionsDelegate)
        self.view.addSubview(postDetailsView)
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
