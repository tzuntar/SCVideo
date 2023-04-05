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

    override func awakeFromNib() {
        super.awakeFromNib()
        postImage.layer.cornerRadius = 8
    }

    @objc func playPressed(_ sender: UIImageView) {
        guard let post = currentPost else { return }
        player = AVPlayer(url: URL(string: post.content_uri)!)
        playerLayer = AVPlayerLayer(player: player)
        let audioSession = AVAudioSession.sharedInstance()
        playerLayer!.frame = postImage.frame
        playerLayer!.videoGravity = .resizeAspectFill
        postView.layer.addSublayer(playerLayer!)
        player?.volume = 1
        player?.play()
        player?.actionAtItemEnd = .none
    }
    
    func loadPost(_ post: Post) {
        currentPost = post
        DispatchQueue.global(qos: .background).async {
            PostLoaderLogic.fetchVideoThumbnail(forPost: self.currentPost!) { image, error in
                guard let image = image, error == nil else {
                    print(error!)
                    DispatchQueue.main.async {
                        self.postImage.image = UIImage(named: "No File")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.postImage.image = UIImage(cgImage: image)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.playPressed))
                    self.postImage.addGestureRecognizer(tap)
                    self.postImage.isUserInteractionEnabled = true
                }
            }
        }
    }

}