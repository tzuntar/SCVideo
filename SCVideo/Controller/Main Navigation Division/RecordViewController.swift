//
//  RecordViewController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 11/1/22.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var flipCameraButton: UIButton!
    @IBOutlet weak var deleteClipButton: UIButton!
    @IBOutlet weak var useClipButton: UIButton!
    @IBOutlet weak var recIndicator: UIImageView!
    @IBOutlet weak var timeIndicator: UILabel!
    @IBOutlet weak var recordedClipsView: UIScrollView!

    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var videoDeviceInput: AVCaptureDeviceInput!
    private var _videoOutput: AVCaptureVideoDataOutput!

    private var _assetWriter: AVAssetWriter!
    private var _assetWriterInput: AVAssetWriterInput!
    private var _adapter: AVAssetWriterInputPixelBufferAdaptor?
    private var _filename = ""
    private var _finalAsset: AVURLAsset?
    private var _time: Double = 0
    private var _usingFrontCamera: Bool = false
    var clips: [URL] = []
    var audioPlayer: AVAudioPlayer?

    private var _sessionQueue: DispatchQueue!

    private enum CaptureState {
        case idle, start, capturing, end
    }

    private var captureState = CaptureState.idle

    override func viewDidLoad() {
        super.viewDidLoad()
        _sessionQueue = DispatchQueue(label: "si.scv.SCVideo.Record")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        setUpInputs()
        setUpLivePreview()
        startCameraPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        removeLivePreview()
    }

    private func setUpInputs(usingFrontCamera: Bool = false) {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }

        captureSession.beginConfiguration()
        // remove the inputs if they're already present
        if captureSession.isRunning {
            if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
                for input in inputs {
                    captureSession.removeInput(input)
                }
            }
        }

        // make sure the rear camera and microphone are available
        guard let rearCamera = AVCaptureDevice.default(for: AVMediaType.video),
              let microphone = AVCaptureDevice.default(for: AVMediaType.audio)
        else {
            print("Unable to access capture devices")
            return
        }

        do {
            var cameraInput: AVCaptureDeviceInput?
            if usingFrontCamera {
                // this is necessary because the front camera isn't a default video capture device
                let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
                    deviceTypes: [.builtInWideAngleCamera],
                    mediaType: .video,
                    position: .front)
                if deviceDiscoverySession.devices.count > 0 {
                    let frontCamera = deviceDiscoverySession.devices[0]
                    cameraInput = try AVCaptureDeviceInput(device: frontCamera)
                }
            } else {
                cameraInput = try AVCaptureDeviceInput(device: rearCamera)
            }

            let audioInput = try AVCaptureDeviceInput(device: microphone)
            let output = AVCaptureVideoDataOutput()

            if captureSession.canAddInput(cameraInput!),
               captureSession.canAddInput(audioInput),
               captureSession.canAddOutput(output) {
                captureSession.addInput(cameraInput!)
                captureSession.addInput(audioInput)
                captureSession.addOutput(output)
                videoDeviceInput = cameraInput!
                _videoOutput = output

                _videoOutput.setSampleBufferDelegate(self, queue: _sessionQueue)
            }
        } catch {
            print("Unable to initialize inputs: \(error.localizedDescription)")
        }
        captureSession.commitConfiguration()
    }

    private func setUpLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        videoPreviewLayer.frame = previewView.bounds
    }

    private func removeLivePreview() {
        videoPreviewLayer.removeFromSuperlayer()
    }

    /**
     Starts the capture session in the background
     */
    private func startCameraPreview() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
        }
    }

    private func mergeSegmentsAndUseAsPost(clips _: [URL]) {
        DispatchQueue.main.async {
            let dir = FileManager.default.temporaryDirectory
            let filename = "\(self._filename).mov"
            /*if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filename = "\(self._filename).mov"*/
            VideoCompositionWriter.mergeAudioVideo(dir, filename: filename, clips: self.clips) { success, outUrl in
                if success, let url = outUrl {
                    self._finalAsset = AVURLAsset(url: url)
                    self.performSegue(withIdentifier: "UploadRecorded", sender: self)
                }
            }

            self.indicateRecordingState()
        }
    }

    private func indicateRecordingState() {
        switch captureState {
        case .start, .capturing:
            recordButton.setImage(UIImage(named: "Recording Button"), for: .normal)
            timeIndicator.alpha = CGFloat(integerLiteral: 1)
            startFlashingRecIndicator()
        default:
            recordButton.setImage(UIImage(named: "Record Button"), for: .normal)
            stopFlashingRecIndicator()
        }
    }

// MARK: - Control Actions

    @IBAction func recordPressed(_ sender: UIButton) {
        switch captureState {
        case .idle:
            captureState = .start
        case .capturing:
            captureState = .end
        default:
            break
        }
    }

    @IBAction func flipCameraPressed(_ sender: UIButton) {
        _usingFrontCamera = !_usingFrontCamera
        setUpInputs(usingFrontCamera: _usingFrontCamera)
        startCameraPreview()
    }

    @IBAction func deleteClipPressed(_ sender: UIButton) {
    }

    @IBAction func useClipPressed(_ sender: Any) {
        guard clips.count > 0 else { return }
        #if ENABLE_MULTI_CLIP
            mergeSegmentsAndUseAsPost(clips: clips)
        #else
            DispatchQueue.main.async {
                self._finalAsset = AVURLAsset(url: self.clips.last!)
                self.performSegue(withIdentifier: "UploadRecorded", sender: self)
                self.indicateRecordingState()
            }
        #endif
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UploadRecorded" {
            let uploadVC = segue.destination as! UploadViewController
            if let asset = _finalAsset {
                uploadVC.selectedAsset = asset
            }
        }
    }
}

// MARK: - Animations & User Interface Updates
extension RecordViewController {

    // FixMe: fix these opacity shenanigans
    private func startFlashingRecIndicator() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction]) {
            self.recIndicator.alpha = 1.0
        }
        //recIndicator.alpha = 1.0    // one's here
    }

    private func stopFlashingRecIndicator() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: [.curveEaseInOut, .repeat, .autoreverse, .allowUserInteraction]) {
            self.recIndicator.alpha = 0.0
        }
        //recIndicator.alpha = 0.0    // here's another
    }

    private func setTimeIndicator(toSeconds seconds: Int) {
        let minutes = seconds / 60
        let seconds = seconds % 60
        timeIndicator.text = String(format: "%02d:%02d", minutes, seconds)
    }

    private func reloadClipsView() {
        for subview in recordedClipsView.subviews {
            subview.removeFromSuperview()
        }
        for clip in clips {
            let template = UINib(nibName: "RecordedClipCell", bundle: nil)
            guard let view = template.instantiate(withOwner: self, options: nil).first as? RecordedClipCell else {
                continue
            }
            view.configure(forClip: AVAsset(url: clip))
            recordedClipsView.addSubview(view)

            //view.translatesAutoresizingMaskIntoConstraints = false
            let lastSubview = recordedClipsView.subviews.last
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: recordedClipsView.topAnchor),
                view.bottomAnchor.constraint(equalTo: recordedClipsView.bottomAnchor),
                view.leadingAnchor.constraint(equalTo: lastSubview != nil
                        ? lastSubview!.leadingAnchor
                        : recordedClipsView.leadingAnchor),
           ]);
        }
    }

}

// MARK: - Sample Buffer Delegate
extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch captureState {
        case .start:
            DispatchQueue.main.async {
                self.indicateRecordingState()
            }

            _filename = UUID().uuidString // uuid-based clip filename
            let clipUrl = FileManager.default.temporaryDirectory.appendingPathComponent("(\(_filename).mov")
            clips.append(clipUrl)
            /*let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("(\(_filename).mov")*/
            let writer = try! AVAssetWriter(outputURL: clipUrl, fileType: .mov)

            // AVAssetWriterInput is used to mix down the audio tracks
            let settings = _videoOutput!.recommendedVideoSettingsForAssetWriter(writingTo: .mov)
            let input = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            input.mediaTimeScale = CMTimeScale(bitPattern: 600)
            input.expectsMediaDataInRealTime = true
            input.transform = CGAffineTransform(rotationAngle: .pi / 2)

            // append video samples as pixel buffers to the AVAssetWriterInput
            let adapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: nil)
            if writer.canAdd(input) {
                writer.add(input)
            }

            // start writing to the flash
            let startingTimeDelay = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1_000_000_000)
            writer.startWriting()
            writer.startSession(atSourceTime: .zero + startingTimeDelay)

            _assetWriter = writer
            _assetWriterInput = input
            _adapter = adapter
            captureState = .capturing
            _time = timestamp
        case .capturing:
            if _assetWriterInput?.isReadyForMoreMediaData == true {
                // append the sample buffer at the correct time
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                _adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!,
                                 withPresentationTime: time)
            }
            DispatchQueue.main.async {
                self.setTimeIndicator(toSeconds: Int(timestamp - self._time))
            }
        case .end:
            // write the rest of the video file
            guard _assetWriterInput?.isReadyForMoreMediaData == true,
                  _assetWriter!.status != .failed else { break }
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                self?.captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
            }
            DispatchQueue.main.async {
                self.indicateRecordingState()
                self.reloadClipsView()
            }
        case .idle:
            DispatchQueue.main.async {
                self.indicateRecordingState()
            }
            break
        }
    }
}
