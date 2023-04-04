//
//  PostCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import UIKit
import AVFoundation

class PostCell: UICollectionViewCell {

    @IBOutlet weak var postView: UIView!
    @IBOutlet weak var postImage: UIImageView!

    private var currentPost: Post?
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    @objc func playPressed(_ sender: UIImageView) {
        guard let post = currentPost else { return }
        let frame = self.postImage.frame
    
        player = AVPlayer(url: URL(string: post.content_uri)!)
        playerLayer = AVPlayerLayer(player: player)
        let audioSession = AVAudioSession.sharedInstance()
        playerLayer!.frame = frame
        playerLayer!.videoGravity = .resizeAspectFill
        postView.layer.addSublayer(playerLayer!)
        player?.volume = 1
        player?.play()
        player?.actionAtItemEnd = .none
    }
    
    func loadPost(_ post: Post) {
        self.currentPost = post
        DispatchQueue.global(qos: .background).async {
            let loader = PostLoaderLogic(delegate: self)
            loader.loadVideoPostThumbnail(forPost: post)
        }
    }

}

// MARK: - Post Loading

extension PostCell: PostLoaderDelegate {
    
    func didLoadVideoThumbnail(_ image: CGImage) {
        DispatchQueue.main.async {
            self.postImage.image = UIImage(cgImage: image)
            let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.playPressed))
            self.postImage.addGestureRecognizer(tap)
            self.postImage.isUserInteractionEnabled = true
        }
    }
    
    func didLoadingFailWithError(_ error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.postImage.image = UIImage(named: "No File")
        }
    }
    
}
