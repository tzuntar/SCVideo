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
    
    let session: UserSession
    let delegate: FriendDelegate
    
    init(session: UserSession, withDelegate delegate: FriendDelegate) {
        self.session = session
        self.delegate = delegate
    }
    
    func retrieveFriends() {
        AF.request(APIURL + "/users/friends",
                   headers: [.authorization(bearerToken: self.session.token)])
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
        AF.request(APIURL + "/users/" + String(user.id_user) + "/add_friend",
                   headers: [.authorization(bearerToken: self.session.token)])
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
