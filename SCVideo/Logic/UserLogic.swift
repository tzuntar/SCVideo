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
    
    private func handleError(forCode responseCode: Int) {
        switch responseCode {
        case 500:
            delegate.didLoadingFailWithError(UserAccountError.noData)
        default:
            delegate.didLoadingFailWithError(UserAccountError.unexpected(code: responseCode))
        }
    }
}
