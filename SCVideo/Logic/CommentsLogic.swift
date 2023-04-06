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

    let delegate: CommentsDelegate

    init(delegatingActionsTo delegate: CommentsDelegate) {
        self.delegate = delegate
    }

    func retrieveComments(forPost post: Post) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/posts/\(post.id_post)/comments",
                headers: authHeaders)
            .validate()
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
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/posts/\(commentEntry.id_post)/comment",
                   method: .post,
                   parameters: commentEntry,
                   encoder: JSONParameterEncoder.default,
                   headers: authHeaders)
            .validate()
            .response { response in
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
