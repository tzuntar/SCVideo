//
//  FeedLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import Foundation
import Alamofire

class FeedLogic {
    
    let session: UserSession
    
    init(withSession session: UserSession) {
        self.session = session
    }
    
    func loadPostBatch(limit: Int, offset: Int?, completion: @escaping ([Post]?, _ errorCode: Int?) -> Void) {
        let params: Parameters = [
            "limit": limit,
            "offset": offset ?? 0
        ]
        AF.request("\(APIURL)/posts/feed/",
                   parameters: params,
                   encoding: URLEncoding(destination: .queryString),
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
