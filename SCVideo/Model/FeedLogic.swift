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
    
    let delegate: FeedDelegate
    
    init(session: UserSession, withDelegate delegate: FeedDelegate) {
        self.session = session
        self.delegate = delegate
    }
    
    func retrieveFeedPosts() {
        AF.request(APIURL + "/posts/feed",
                   headers: [.authorization(bearerToken: self.session.token)]).validate()
            .responseDecodable(of: [Post].self) { response in
                if let safeResponse = response.value {
                    self.delegate.didFetchPosts(safeResponse)
                    return
                }
                
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate.didFetchingFailWithError(FeedError.noData)
        default:
            delegate.didFetchingFailWithError(FeedError.unexpected(code: responseCode))
        }
    }
    
}
