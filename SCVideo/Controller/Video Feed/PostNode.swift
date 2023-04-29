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
        videoNode = ASVideoNode()//FeedVideoNode()
        gradientNode = GradientNode()
        super.init()

        PostLoaderLogic.fetchVideoThumbnail(forPost: post) { (image: CGImage?, error: Error?) in
            if let img = image {
                self.thumbnailNode.image = UIImage(cgImage: img)
            } else {
                if let e = error {
                    print("Fetching thumbnail for post \(post.id_post) failed: \(e.localizedDescription)")
                }
                self.thumbnailNode.image = UIImage(named: "No File")
            }
        }
        thumbnailNode.contentMode = .scaleAspectFill
        
        // ASD recommends enabling layer-backing in any custom node
        // that doesn't need touch handling for better performance
        gradientNode.isLayerBacked = true
        gradientNode.isOpaque = false
        
        //videoNode.url = post.thumbnail_url
        videoNode.delegate = self
        videoNode.muted = true  // ToDo: properly autoplay sound
        videoNode.shouldAutoplay = true
        videoNode.shouldAutorepeat = false
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue

        addSubnode(videoNode)
        addSubnode(gradientNode)
    }
    
    override func didLoad() {
        super.didLoad()
        // set the asset on the main thread since the nodes aren't on it
        videoNode.assetURL = URL(string: "\(APIURL)/posts/videos/\(post.content_uri)")!

        // all UIView calls _must_ be done on the main thread
        let postControlsView = PostControlsView()
        postControlsView.frame = CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 70, y: 300),
                                        size: CGSize(width: 63, height: 240))
        postControlsView.setPost(post: post)
        postControlsView.setDelegate(delegate: nodeActionsDelegate)
        view.addSubview(postControlsView)

        let postDetailsView = PostDetails()
        postDetailsView.frame = CGRect(origin: CGPoint(x: 0, y: UIScreen.main.bounds.height - 170),
                                       size: CGSize(width: 414, height: 141))
        postDetailsView.setPost(post: post)
        postDetailsView.setDelegate(delegate: nodeActionsDelegate)
        view.addSubview(postDetailsView)
        
        // necessary for the sound to work as playback sound instead of
        // the OS treating it as notification sound
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            print("Setting sound to 'playback' failed, video sound will be treated as notification sound!")
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

// MARK: - Video Node Delegate

extension PostNode: ASVideoNodeDelegate {

    func didTap(_ videoNode: ASVideoNode) {
        videoNode.muted = !videoNode.muted
    }
    
}
