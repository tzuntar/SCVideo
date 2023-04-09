//
//  UserLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 11/18/22.
//

import Foundation
import Alamofire

protocol UserAccountDelegate {
    func didLoadUserData(_ user: User)
    func didLoadingFailWithError(_ error: Error)
}

enum UserAccountError: Error, CustomStringConvertible {
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

class UserLogic {

    let delegate: UserAccountDelegate

    init(delegatingActionsTo delegate: UserAccountDelegate) {
        self.delegate = delegate
    }

    /**
     Retrieves the user data from the server.
     - Parameters:
        - user: The user whose data is to be retrieved.
     */
    func retrieveData(forUser user: User) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request(APIURL + "/users/" + String(user.id_user) + "/account",
                   headers: authHeaders)
            .validate()
            .responseDecodable(of: User.self) { response in
                if let safeResponse = response.value {
                    self.delegate.didLoadUserData(safeResponse)
                    return
                }
                
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }

    /**
     Uploads a new avatar image to the server.
     - Parameters:
        - image: The image to be uploaded.
        - completion: The completion handler to be called when the upload is finished.
     */
    static func uploadNewAvatar(_ image: UIImage, completion: @escaping (Result<User, Error>) -> Void) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        let filename = "avatar_" + String(AuthManager.shared.session!.user.identifier)
        AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(image.jpegData(compressionQuality: 0.5)!,
                                             withName: "photo",
                                             fileName: "\(filename).jpg",
                                             mimeType: "image/jpg")
                }, to: "\(APIURL)/users/avatar", method: .post, headers: authHeaders)
            .validate()
            .responseDecodable(of: User.self) { response in
                if let safeResponse = response.value {
                    completion(.success(safeResponse))
                    return
                }

                if let safeResponse = response.response {
                    completion(.failure(UserAccountError.unexpected(code: safeResponse.statusCode)))
                }
        }
    }

    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate.didLoadingFailWithError(UserAccountError.noData)
        default:
            delegate.didLoadingFailWithError(UserAccountError.unexpected(code: responseCode))
        }
    }
}
