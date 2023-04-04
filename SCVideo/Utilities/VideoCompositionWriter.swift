//
//  VideoCompositionWriter.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 2/25/23.
//

import Foundation
import AVFoundation

class VideoCompositionWriter {

    private static func mergeClips(_ clips: [AVAsset], completion: @escaping (Result<AVAsset, Error>) -> Void) {
        if clips.count < 1 {
            return completion(.failure(NSError(domain: "si.scv.scvideo",
                                               code: 0,
                                               userInfo: [NSLocalizedDescriptionKey: "No clips to merge"])))
        }
        let composition = AVMutableComposition()
        do {
            let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)

            for clip in clips { // fails down here!
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
    static func mergeAudioVideo(_ directory: URL, filename: String, clips: [URL], completion: @escaping (Bool, URL?) -> Void) {
        var assets: [AVAsset] = []
        var totalDuration = CMTime.zero
        
        for clip in clips {
            let asset = AVURLAsset(url: clip)
            assets.append(asset)
            totalDuration = CMTimeAdd(totalDuration, asset.duration)
        }

        mergeClips(assets) { (result: Result<AVAsset, Error>) in
            switch result {
            case .success(let composition):
                let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetMediumQuality)
                exporter?.outputURL = directory.appendingPathComponent(filename)
                exporter?.outputFileType = .mov
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
    }

}
