//
//  UploadViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/25/22.
//

import UIKit
import AVFoundation

class UploadViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var videoPreviewBox: UIImageView!
    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var postDescriptionBox: UITextView!
    
    var currentSession: UserSession?
    var postLogic: PostLogic?
    var videoPicker: UIImagePickerController?
    var selectedAsset: AVURLAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoPreviewBox.layer.borderWidth = 2
        videoPreviewBox.layer.borderColor = UIColor.white.cgColor
        videoPreviewBox.layer.cornerRadius = 10
        
        if let safeSession = currentSession {
            postLogic = PostLogic(session: safeSession, withDelegate: self)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPicker = UIImagePickerController()
        if let picker = videoPicker {
            picker.delegate = self
            picker.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
            if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
                goBack()
                return
            }
            if let types = UIImagePickerController.availableMediaTypes(for: picker.sourceType) {
                if !types.contains("public.movie") {
                    goBack()
                    return
                }
            }
            picker.mediaTypes = ["public.movie"]
            picker.allowsEditing = true
            present(picker, animated: true)
        }
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let logic = postLogic,
              let session = currentSession else {
            print("Initialization failed!")
            return
        }
        guard let description = postDescriptionBox.text,
              let asset = selectedAsset else { return }
        postDescriptionBox.endEditing(true)
        logic.postVideo(with: NewPostEntry(
                        id_user: session.user.id_user,
                        type: "video",
                        videoFile: asset,
                        title: nil,
                        description: description))
    }
    
    private func goBack() {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 1
        }
    }

}

// MARK: - Post Delegate Division

extension UploadViewController: PostingDelegate {
    
    func didPostSuccessfully() {
        // signal that the post was posted
        goBack()
    }
    
    func didPostingFailWithError(_ error: Error) {
        print(error)
    }
    
}

// MARK: - Video Picker Handling Division

extension UploadViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        goBack()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let url = info[.mediaURL] as? NSURL {
            let asset = AVURLAsset(url: url.absoluteURL!)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            do {
                self.selectedAsset = asset
                let previewCgImage = try imgGenerator
                    .copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                videoPreviewBox.image = UIImage(cgImage: previewCgImage)
                
                filenameLabel.text = url.lastPathComponent
                let minutes = Int(asset.duration.seconds) / 60
                let seconds = Int(asset.duration.seconds) % 60
                
                if let fileSize = PostLogic.getAssetSize(forLocalUrl: asset.url) {  // 0 MB, 00:00
                    let size = String(format: "%.2f", Double(fileSize) / 1024 / 1024)
                    fileSizeLabel.text = size + " MB, " +
                        String(format: "%02i:%02i", minutes, seconds)
                } else {    // No file size available, use format 00:00
                    fileSizeLabel.text = String(format: "%02i:%02i", minutes, seconds)
                }
            } catch let error {
                print(error)
                goBack()
                return
            }
        }
    }
}
