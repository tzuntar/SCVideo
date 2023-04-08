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
    @IBOutlet weak var postTitleBox: UITextField!
    @IBOutlet weak var postDescriptionBox: UITextView!
    @IBOutlet weak var postDescriptionPlaceholderLabel: UILabel!
    @IBOutlet weak var stackViewBottom: NSLayoutConstraint!

    var postLogic: PostLogic?
    var videoPicker: UIImagePickerController?
    var selectedAsset: AVURLAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        // Notification Center for keyboard handling
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification,
                object: nil);
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification,
                object: nil);

        videoPreviewBox.layer.borderWidth = 2
        videoPreviewBox.layer.borderColor = UIColor.white.cgColor
        videoPreviewBox.layer.cornerRadius = 10
        postTitleBox.layer.borderWidth = 2
        postTitleBox.layer.borderColor = UIColor.white.cgColor
        postTitleBox.layer.cornerRadius = 10
        postDescriptionBox.layer.borderWidth = 2
        postDescriptionBox.layer.borderColor = UIColor.white.cgColor
        postDescriptionBox.layer.cornerRadius = 10

        // used to manually hide the placeholder text
        postDescriptionBox.delegate = self

        postLogic = PostLogic(delegatingActionsTo: self)
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
            if let asset = selectedAsset {
                loadAssetDetails(forAsset: asset)
            } else {
                present(picker, animated: true)
            }
        }
    }
    
    @IBAction func postButtonPressed(_ sender: UIButton) {
        guard let asset = selectedAsset else { return }
        guard let title = postTitleBox.text else {
            postTitleBox.layer.borderColor = UIColor(named: "ButtonColor")?.cgColor
            postTitleBox.becomeFirstResponder()
            return
        }
        postTitleBox.endEditing(true)
        postDescriptionBox.endEditing(true)
        postLogic!.postVideo(with: NewPostEntry(
                             type: "video",
                        videoFile: asset,
                            title: title,
                      description: postDescriptionBox.text))
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if postTitleBox.isEditing || postDescriptionBox.isFirstResponder {
            moveViewWithKeyboard(notification, viewBottomConstraint: stackViewBottom, keyboardWillShow: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        moveViewWithKeyboard(notification, viewBottomConstraint: stackViewBottom, keyboardWillShow: false)
    }

    private func goBack() {
        dismiss(animated: true)
    }
    
    private func loadAssetDetails(forAsset asset: AVURLAsset) {
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            selectedAsset = asset
            let previewCgImage = try imgGenerator
                .copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            videoPreviewBox.image = UIImage(cgImage: previewCgImage)
            
            filenameLabel.text = asset.url.lastPathComponent
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
            loadAssetDetails(forAsset: asset)
        }
    }
}

// MARK - Description Text View Delegate

extension UploadViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        postDescriptionPlaceholderLabel.isHidden = true
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "") {
            postDescriptionPlaceholderLabel.isHidden = false
        }
    }
}
