//
//  PostLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 11/1/22.
//

import AVFoundation
import Alamofire

struct NewPostEntry {
    let id_user: Int
    let type: String
    let videoFile: AVURLAsset
    let title: String?
    let description: String?
}

protocol PostingDelegate {
    func didPostSuccessfully()
    func didPostingFailWithError(_ error: Error)
}

protocol PostLoaderDelegate {
    func didLoadVideoThumbnail(_ image: CGImage)
    func didLoadingFailWithError(_ error: Error)
}

protocol PostActionsDelegate {
    func didLikePost(_ post: Post)
    func didUnlikePost(_ post: Post)
    func didActionFailWithError(_ error: Error)
}

enum PostingError: Error, CustomStringConvertible {
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .unexpected(_):
            return "Napaka"
        }
    }
}

enum PostActionError: Error, CustomStringConvertible {
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .unexpected(_):
            return "Napaka"
        }
    }
}

class PostLoaderLogic {
    
    let delegate: PostLoaderDelegate
    
    init(delegate: PostLoaderDelegate) {
        self.delegate = delegate
    }
    
    func loadVideoPostThumbnail(forPost post: Post) {
        if post.type != PostType.video.rawValue { return }
        
        let asset = AVURLAsset(url: URL(string: post.content_uri)!)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            delegate.didLoadVideoThumbnail(cgImage)
        } catch let error {
            delegate.didLoadingFailWithError(error)
        }
    }
    
    static func fetchVideoThumbnail(forPost post: Post, completion: @escaping (CGImage?, Error?) -> Void) {
        // ToDo: display the No File image on errors
        let asset = AVURLAsset(url: URL(
            string: "\(APIURL)/posts/videos/\(post.content_uri)")!)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            completion(cgImage, nil)
        } catch let error {
            completion(nil, error)
        }
    }
    
}

class PostActionsLogic {
    
    let session: UserSession
    let delegate: PostActionsDelegate
    
    init(session: UserSession, withDelegate delegate: PostActionsDelegate) {
        self.session = session
        self.delegate = delegate
    }
    
    func toggleLike(_ post: Post) {
        if post.is_liked == 1 {
            unlike(post)
        } else {
            like(post)
        }
    }
    
    func like(_ post: Post) {
        AF.request(APIURL + "/posts/" + String(post.id_post) + "/like",
                   method: .post,
                   headers: [.authorization(bearerToken: session.token)])
            .validate()
            .response() { response in
                if let safeResponse = response.response {
                    if safeResponse.statusCode == 200 {
                        post.is_liked = 1
                        self.delegate.didLikePost(post)
                    } else {
                        self.handleError(forCode: safeResponse.statusCode)
                    }
                }
            }
    }
    
    func unlike(_ post: Post) {
        AF.request(APIURL + "/posts/" + String(post.id_post) + "/unlike",
                   method: .post,
                   headers: [.authorization(bearerToken: session.token)])
            .validate()
            .response() { response in
                if let safeResponse = response.response {
                    if safeResponse.statusCode == 200 {
                        post.is_liked = 0
                        self.delegate.didUnlikePost(post)
                    } else {
                        self.handleError(forCode: safeResponse.statusCode)
                    }
                }
            }
    }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        default:
            delegate.didActionFailWithError(PostActionError.unexpected(code: responseCode))
        }
    }
    
}

class PostLogic {
    
    let session: UserSession
    let delegate: PostingDelegate
    
    init(session: UserSession, withDelegate delegate: PostingDelegate) {
        self.session = session
        self.delegate = delegate
    }
    
    func postVideo(with newPostEntry: NewPostEntry) {
        guard let safeData = try? Data(contentsOf: newPostEntry.videoFile.url) else { return }
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(safeData, withName: "video",
                             fileName: newPostEntry.videoFile.url.lastPathComponent)
            multiPart.append(String(newPostEntry.id_user).data(using: .utf8)!, withName: "id_user")
            if let title = newPostEntry.title {
                multiPart.append(title.data(using: .utf8)!, withName: title)
            }
            if let desc = newPostEntry.description {
                multiPart.append(desc.data(using: .utf8)!, withName: "description")
            }
        }, to: APIURL + "/posts/video",
           method: .post,
           headers: [.authorization(bearerToken: self.session.token)])
        .uploadProgress(queue: .main) { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .response() { response in
            if let safeResponse = response.response {
                self.handleError(forCode: safeResponse.statusCode)
            }
        }
    }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 200:
            delegate.didPostSuccessfully()
        default:
            delegate.didPostingFailWithError(PostingError.unexpected(code: responseCode))
        }
    }
    
    public static func getAssetSize(forLocalUrl url: URL) -> Int? {
        do {
            let values = try url.resourceValues(forKeys: [URLResourceKey.fileSizeKey])
            return values.fileSize
        } catch let error {
            print(error)
            return nil
        }
    }
    
}
