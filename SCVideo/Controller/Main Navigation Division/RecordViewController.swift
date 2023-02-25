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
    var clips: [String] = []
    var audioPlayer: AVAudioPlayer?
    
    private final var _RECORD_THREAD_NAME: String = "eu.tobija-zuntar.SCVideo.record"
    
    private enum _CaptureState {
        case idle, start, capturing, end
    }
    
    private var _captureState = _CaptureState.idle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession = AVCaptureSession()
        
        // make sure the rear camera and microphone are available
        guard let rearCamera = AVCaptureDevice.default(for: AVMediaType.video),
              let microphone = AVCaptureDevice.default(for: AVMediaType.audio)
        else {
            debugPrint("Unable to access capture devices")
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: rearCamera)
            let audioInput = try AVCaptureDeviceInput(device: microphone)
            let output = AVCaptureVideoDataOutput()
            
            if captureSession.canAddInput(cameraInput),
               captureSession.canAddInput(audioInput),
               captureSession.canAddOutput(output) {
                captureSession.addInput(cameraInput)
                captureSession.addInput(audioInput)
                captureSession.addOutput(output)
                videoDeviceInput = cameraInput
                _videoOutput = output

                _videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: _RECORD_THREAD_NAME))
                setUpLivePreview()
            }
            
        } catch {
            debugPrint("Unable to initialize inputes: \(error.localizedDescription)")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setUpLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        
        previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        
        // start the capture session in the background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession?.startRunning()
            
            // set the frame of the preview layer on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    private func mergeSegmentsAndUseAsPost(clips _: [String]) {
        DispatchQueue.main.async {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let filename = "\(self._filename).mov"
                VideoCompositionWriter.mergeAudioVideo(dir, filename: filename, clips: self.clips) { success, outUrl in
                    if success, let url = outUrl {
                        self._finalAsset = AVURLAsset(url: url)
                        self.performSegue(withIdentifier: "UploadRecorded", sender: self)
                    }
                }
                
                // ToDo: UI changes
                //self.stopAnimatingRecordButton()
            }
        }
    }
    
// MARK: - Control Actions

    @IBAction func recordPressed(_ sender: UIButton) {
        switch _captureState {
        case .idle:
            _captureState = .start
        case .capturing:
            _captureState = .end
        default:
            break
        }
    }
    
    @IBAction func flipCameraPressed(_ sender: UIButton) {
    }
    
    @IBAction func deleteClipPressed(_ sender: UIButton) {
    }
    
    @IBAction func useClipPressed(_ sender: Any) {
        self.mergeSegmentsAndUseAsPost(clips: clips)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let uploadVC = segue.destination as? UploadViewController,
           let asset = _finalAsset {
            uploadVC.selectedAsset = asset
        }
    }
}

// MARK: - Sample Buffer Delegate
extension RecordViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds
        switch _captureState {
        case .start:
            // ToDo: animate the record button
            // self.animateRecordButton()
            
            _filename = UUID().uuidString // uuid-based clip filename
            clips.append("\(_filename).mov")
            let videoPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                .appendingPathComponent("(\(_filename).mov")
            
            let writer = try! AVAssetWriter(outputURL: videoPath, fileType: .mov)
            
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
            _captureState = .capturing
            _time = timestamp
        case .capturing:
            // ToDo: UI changes
            if _assetWriterInput?.isReadyForMoreMediaData == true {
                // append the sample buffer at the correct time
                let time = CMTime(seconds: timestamp - _time, preferredTimescale: CMTimeScale(600))
                _adapter?.append(CMSampleBufferGetImageBuffer(sampleBuffer)!,
                                 withPresentationTime: time)
            }
        case .end:
            // ToDo: UI changes
            // write the rest of the video file
            guard _assetWriterInput?.isReadyForMoreMediaData == true,
                  _assetWriter!.status != .failed else { break }
            _assetWriterInput?.markAsFinished()
            _assetWriter?.finishWriting { [weak self] in
                self?._captureState = .idle
                self?._assetWriter = nil
                self?._assetWriterInput = nil
                // ToDo: stop animating the record button
                // DispatchQueue.main.async { self?.stopAnimatingRecordButton() }
            }
            break
        case .idle:
            // ToDo: UI changes
            // ToDo: stop animating the record button
            // DispatchQueue.main.async { self?.stopAnimatingRecordButton() }
            break
        }
    }
}
