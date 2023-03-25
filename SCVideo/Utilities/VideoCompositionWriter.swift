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

        let mixComposition = merge(clips: assets)
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
        }
    }

}
