//
//  RecordedClipCell.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 4/2/23.
//

import UIKit

class RecordedClipCell: UITableViewCell {

    var clip: AVAsset?

    @IBOutlet weak var clipImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        /*contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 2.0
        contentView.layer.borderColor = UIColor.white.cgColor*/
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func configure(forClip clip: AVAsset) {
        self.clip = clip
        let imageGenerator = AVAssetImageGenerator(asset: clip)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMake(value: 1, timescale: 2)
        do {
            let thumbnail = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            clipImage.image = UIImage(cgImage: thumbnail)
        } catch let error {
            print("Generating preview clip failed: \(error)")
        }
    }

}
