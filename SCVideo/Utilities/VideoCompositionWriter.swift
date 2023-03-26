//
//  VideoCompositionWriter.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/25/23.
//

import Foundation
import AVFoundation

class VideoCompositionWriter {
    
    /*private static func merge(videos: [AVAsset]) -> AVMutableComposition {
        let mainComposition = AVMutableComposition()
        let compositionVideoTrack = mainComposition.addMutableTrack(withMediaType: .video,
                                                                    preferredTrackID: kCMPersistentTrackID_Invalid)
        compositionVideoTrack?.preferredTransform = CGAffineTransform(rotationAngle: .pi / 2)
        
        // add all video assets to the track starting at time = 0
        var insertTime = CMTime.zero
        for videoAsset in videos {
            try! compositionVideoTrack?.insertTimeRange(
                CMTimeRangeMake(start: .zero,
                                duration: videoAsset.duration),
                of: videoAsset.tracks(withMediaType: .video)[0],
                at: insertTime)
            insertTime = CMTimeAdd(insertTime, videoAsset.duration)
        }
        
        return mainComposition
    }*/
    
    private static func merge(clips: [AVAsset]) -> AVMutableComposition {
        let composition = AVMutableComposition()
        var currentTime = CMTime.zero
        for clip in clips {
            let timeRange = CMTimeRangeMake(start: .zero, duration: clip.duration)
            do {
                try composition.insertTimeRange(timeRange, of: clip, at: currentTime)
            } catch {
                print("Failed to insert time range: \(error)")
            }
            currentTime = CMTimeAdd(currentTime, clip.duration)
        }
        return composition
    }
    
    private static func mergeClips(_ clips: [AVAsset], completion: @escaping (Result<AVAsset, Error>) -> Void) {
        guard let firstClip = clips.first else {
            return completion(.failure(NSError(domain: "com.tzuntar.scvideo",
                                               code: 0,
                                               userInfo: [NSLocalizedDescriptionKey: "No clips to merge"])))
        }
        let composition = AVMutableComposition()
        do {
            let videoTracks = firstClip.tracks(withMediaType: .video)
            let audioTracks = firstClip.tracks(withMediaType: .audio)
            
            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

            for clip in clips {
                try clip.loadTracks(withMediaType: .video) { (tracks: [AVAssetTrack]?, error: Error?) throws -> Void in
                    guard error == nil, let tracks = tracks else {
                        print("Error loading tracks: \(error?.localizedDescription)")
                        return
                    }

                    let timeRange = CMTimeRangeMake(start: .zero, duration: clip.duration)
                    try videoCompositionTrack?.insertTimeRange(timeRange,
                                                               of: tracks[0],
                                                               at: composition.duration)
                }
                
                try videoCompositionTrack?.insertTimeRange(
                    CMTimeRangeMake(start: .zero, duration: clip.duration),
                    of: clip.tracks(withMediaType: .video)[0],
                    at: composition.duration)
                try audioCompositionTrack?.insertTimeRange(
                    CMTimeRangeMake(start: .zero, duration: clip.duration),
                    of: clip.tracks(withMediaType: .audio)[0],
                    at: composition.duration)
                completion(.success(composition))
            }
        } catch {
            completion(.failure(error))
        }
    }

    /**
     Merges video tracks specified as filenames in the clips array into a
     final video file and saves it under this filename.
     */
    static func mergeAudioVideo(_ directory: URL, filename: String, clips: [String], completion: @escaping (Bool, URL?) -> Void) {
        var assets: [AVAsset] = []
        var totalDuration = CMTime.zero
        
        for clip in clips {
            let videoFile = directory.appendingPathComponent(clip)
            let asset = AVURLAsset(url: videoFile)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }

        
        mergeClips(assets) { (result: Result<AVAsset, Error>) in
            switch result {
            case .success(let composition):
                let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
                let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("filename")
                exporter?.outputURL = tempUrl
                exporter?.outputFileType = .mp4
                exporter?.shouldOptimizeForNetworkUse = true
                
                exporter?.exportAsynchronously(completionHandler: {
                    switch exporter?.status {
                    case .completed:
                        completion(true, exporter?.outputURL)
                    default:
                        completion(false, nil) // error
                    }
                })
            case .failure(let error):
                print(error)
                completion(false, nil);
            }
        }
        
        /*let mixComposition = merge(clips: assets)
        let url = directory.appendingPathComponent("Out").appendingPathComponent(filename)
        guard let exporter = AVAssetExportSession(asset: mixComposition,
                                                  presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = url
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        
        exporter.exportAsynchronously {
            DispatchQueue.main.async {
                if exporter.status == .completed {
                    completion(true, exporter.outputURL)
                } else {
                    completion(false, nil)
                }
            }
        }*/
    }

}
