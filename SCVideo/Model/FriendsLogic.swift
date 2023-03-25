//
//  FriendsLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/31/22.
//

import Foundation
import Alamofire

protocol FriendDelegate {
    func didFriendActionFailWithError(_ error: Error)
}

protocol FriendListDelegate : FriendDelegate {
    func didFetchFriends(_ friends: [User])
}

protocol AddFriendDelegate : FriendDelegate {
    func didAddSucceed(_ friend: User)
}

enum FriendsError: Error, CustomStringConvertible {
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

class FriendsLogic {

    let delegate: FriendDelegate
    
    init(delegatingActionsTo delegate: FriendDelegate) {
        self.delegate = delegate
    }
    
    func retrieveFriends() {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request(APIURL + "/users/friends", headers: authHeaders)
            .validate()
            .responseDecodable(of: [User].self) { response in
                if let safeResponse = response.value,
                   let d = self.delegate as? FriendListDelegate {
                    d.didFetchFriends(safeResponse)
                    return
                }
                
                if let safeResponse = response.response {
                    self.handleError(forCode: safeResponse.statusCode)
                }
            }
    }
    
    func addFriend(user: User) {
        guard let authHeaders = AuthManager.shared.getAuthHeaders() else { return }
        AF.request("\(APIURL)/users/\(user.id_user)/add_friend",
                   headers: authHeaders)
            .validate()
            .response() { response in
                if let d = self.delegate as? AddFriendDelegate {
                    d.didAddSucceed(user)
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
            delegate.didFriendActionFailWithError(FriendsError.noData)
        default:
            delegate.didFriendActionFailWithError(FriendsError.unexpected(code: responseCode))
        }
    }
}
