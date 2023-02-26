//
//  FeedLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import Foundation
import Alamofire

protocol FeedDelegate {
    func didFetchPosts(_ posts: [Post])
    func didFetchingFailWithError(_ error: Error)
}

enum FeedError: Error, CustomStringConvertible {
    case noData
    case unexpected(code: Int)
    
    public var description: String {
        switch self {
        case .noData:
            return "Ni podatkov"
        case .unexpected(_):
            return "Napaka"
        }
    }
}

class FeedLogic {
    
    let session: UserSession
    
    init(withSession session: UserSession) {
        self.session = session
    }
    
    func retrieveFeedPosts() {
        debugPrint("retrieveFeedPosts IS DEPRECATED!")
        return
    }
    
    func loadPostBatch(limit: Int, leftOffAtPostId lastId: Int?, completion: @escaping ([Post]?, _ errorCode: Int?) -> Void) {
        if let id = lastId {
            AF.request("\(APIURL)/posts/feed/\(id)",
                       parameters: ["limit": limit],
                       headers: [.authorization(bearerToken: self.session.token)])
                .validate()
                .responseDecodable(of: [Post].self) { response in
                    if let safeResponse = response.value {
                        return completion(safeResponse, nil)
                    } else if let safeResponse = response.response {
                        return completion(nil, safeResponse.statusCode)
                    }
                }
        } else {
            AF.request("\(APIURL)/posts/feed/",
                       headers: [.authorization(bearerToken: self.session.token)]).validate()
                .responseDecodable(of: [Post].self) { response in
                    if let safeResponse = response.value {
                        return completion(safeResponse, nil)
                    } else if let safeResponse = response.response {
                        return completion(nil, safeResponse.statusCode)
                    }
                }
        }
    }
    
}
