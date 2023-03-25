//
//  FeedLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/27/22.
//

import Foundation
import Alamofire

class FeedLogic {

    func loadPostBatch(limit: Int, offset: Int?, completion: @escaping ([Post]?, _ errorCode: Int?) -> Void) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        let params: Parameters = [
            "limit": limit,
            "offset": offset ?? 0
        ]
        AF.request("\(APIURL)/posts/feed/",
                   parameters: params,
                   encoding: URLEncoding(destination: .queryString),
                   headers: authHeaders)
            .validate()
            .responseDecodable(of: [Post].self) { response in
                if let safeResponse = response.value {
                    return completion(safeResponse, nil)
                } else if let safeResponse = response.response {
                    return completion(nil, safeResponse.statusCode)
                }
            }
    }
    
}
