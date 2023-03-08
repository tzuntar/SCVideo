//
//  CommentsLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/29/22.
//

import Foundation
import Alamofire

protocol CommentsDelegate {
    func didFetchComments(_ comments: [Comment])
    func didPostCommentSuccessfully()
    func didFetchingFailWithError(_ error: Error)
}

struct CommentEntry: Codable {
    let id_post: Int
    let id_user: Int
    let content: String
}

enum CommentsError: Error, CustomStringConvertible {
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

class CommentsLogic {

    let session: UserSession
    let delegate: CommentsDelegate

    init(session: UserSession, withDelegate delegate: CommentsDelegate) {
        self.session = session
        self.delegate = delegate
    }

    func retrieveComments(forPost post: Post) {
        AF.request(APIURL + "/posts/" + String(post.id_post) + "/comments",
                headers: [.authorization(bearerToken: self.session.token)]).validate()
                .responseDecodable(of: [Comment].self) { response in
                    if let safeResponse = response.value {
                        self.delegate.didFetchComments(safeResponse)
                        return
                    }

                    if let safeResponse = response.response {
                        self.handleError(forCode: safeResponse.statusCode)
                    }
                }
    }
    
    func postComment(with commentEntry: CommentEntry) {
        AF.request(APIURL + "/posts/" + String(commentEntry.id_post) + "/comment",
                   method: .post,
                   parameters: commentEntry,
                   encoder: JSONParameterEncoder.default,
                   headers: [.authorization(bearerToken: self.session.token)])
            .validate()
            .response() { response in
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }

    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 200:
            delegate.didPostCommentSuccessfully()
        case 500:
            delegate.didFetchingFailWithError(CommentsError.noData)
        default:
            delegate.didFetchingFailWithError(CommentsError.unexpected(code: responseCode))
        }
    }

}
