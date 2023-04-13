//
//  EditablePostCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/5/23.
//

import UIKit
import AVFoundation

class EditablePostCell: UITableViewCell {

    @IBOutlet weak var postThumbnail: UIImageView!
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postDescription: UILabel!
    @IBOutlet weak var postTimestamp: UILabel!

    private var currentPost: Post?

    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        postThumbnail.layer.cornerRadius = 8
    }

    func configure(for post: Post) {
        currentPost = post
        postTitle.text = post.title
        postDescription.text = post.description
        if post.description == nil || post.description == "" {
            postDescription.text = "Ni opisa"
            postDescription.font = UIFont(name: "NunitoSans-SemiBoldItalic", size: 20.0)
            postDescription.textColor = UIColor(named: "DescriptionTextLabel")
        }
        postTimestamp.text = DateHelper.formatStringAsDate(post.added_on)
        DispatchQueue.global(qos: .background).async {
            PostLoaderLogic.fetchVideoThumbnail(forPost: post) { image, error in
                guard let image = image, error == nil else {
                    print(error!)
                    DispatchQueue.main.async {
                        self.postThumbnail.image = UIImage(named: "No File")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.postThumbnail.image = UIImage(cgImage: image)
                }
            }
        }
    }

    private func playPressed(_ sender: UIImageView) {
        guard let post = currentPost else { return }
        player = AVPlayer(url: URL(string: post.content_uri)!)
        playerLayer = AVPlayerLayer(player: player)
        let audioSession = AVAudioSession.sharedInstance()
        playerLayer!.frame = postThumbnail.frame
        playerLayer!.videoGravity = .resizeAspectFill
        postThumbnail.layer.addSublayer(playerLayer!)
        player?.volume = 0
        player?.play()
        player?.actionAtItemEnd = .none
    }

}
