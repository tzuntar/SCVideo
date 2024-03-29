//
//  PostLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 11/1/22.
//

import AVFoundation
import Alamofire

struct NewPostEntry {
    let type: String
    let videoFile: AVURLAsset
    let title: String
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
    
    static func loadPostsForUser(_ user: User, completion: @escaping ([Post]?) -> Void) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/users/\(user.id_user)/posts",
                   headers: authHeaders)
        .validate()
        .responseDecodable(of: [Post].self) { response in
            if let safeResponse = response.value {
                return completion(safeResponse)
            }
            return completion(nil)
        }
    }
    
}

class PostActionsLogic {

    let delegate: PostActionsDelegate
    
    init(delegatingActionsTo delegate: PostActionsDelegate) {
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
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/posts/\(post.id_post)/like",
                   method: .post, headers: authHeaders)
            .validate()
            .response { response in
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
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/posts/\(post.id_post)/like",
                   method: .delete,
                   headers: authHeaders)
            .validate()
            .response { response in
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

    static func delete(_ post: Post, completion: @escaping (Bool) -> Void) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        guard post.user?.id_user == AuthManager.shared.session?.user.id_user else { return }
            AF.request(APIURL + "/posts/" + String(post.id_post),
                   method: .delete,
                   headers: authHeaders)
            .validate()
            .response { response in
                if let safeResponse = response.response {
                    if safeResponse.statusCode == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        default:
            delegate.didActionFailWithError(PostActionError.unexpected(code: responseCode))
        }
    }
    
}

class PostLogic {

    let delegate: PostingDelegate
    
    init(delegatingActionsTo delegate: PostingDelegate) {
        self.delegate = delegate
    }
    
    func postVideo(with newPostEntry: NewPostEntry) {
        guard let safeData = try? Data(contentsOf: newPostEntry.videoFile.url) else { return }
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.upload(multipartFormData: { multiPart in
            multiPart.append(safeData, withName: "video",
                             fileName: newPostEntry.videoFile.url.lastPathComponent)
            multiPart.append(String(AuthManager.shared.session!.user.id_user).data(using: .utf8)!, withName: "id_user")
            multiPart.append(newPostEntry.title.data(using: .utf8)!, withName: "title")
            if let desc = newPostEntry.description {
                multiPart.append(desc.data(using: .utf8)!, withName: "description")
            }
        }, to: APIURL + "/posts/video",
           method: .post,
           headers: authHeaders)
        .uploadProgress(queue: .main) { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        }
        .response { response in
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
