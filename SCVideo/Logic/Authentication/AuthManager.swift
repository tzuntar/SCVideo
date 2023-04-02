//
//  AuthManager.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/24/23.
//

import Foundation
import Alamofire
import JWTDecode

class AuthManager {
    static var shared = AuthManager()

    private let refreshURL = "\(APIURL)/refresh"
    private let keychainService = "SCVideo"
    private let keychainAccount = "token"

    var session: UserSession?
    
    private init() {
        session = KeychainHelper.standard.read(service: keychainService,
                                               account: keychainAccount,
                                                  type: UserSession.self)
    }
    
    func startSession(_ session: UserSession) {
        self.session = session
        KeychainHelper.standard.save(session,
                                     service: keychainService,
                                     account: keychainAccount)
    }
    
    func authenticate() -> Bool {
        guard let token = session?.token else { return false }
        do {
            let jwt = try decode(jwt: token.accessToken)
            let expiration = jwt.expiresAt?.timeIntervalSinceNow ?? 0
            if expiration > 0 { // still valid
                return true
            } else {    // expired
                return refreshAccessToken()
            }
        } catch {
            print("Decoding the JWT failed: \(error)")
            return false
        }
    }
    
    private func refreshAccessToken() -> Bool {
        guard let session = session else { return false }
        let params = ["token": session.token.refreshToken]
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        
        AF.request(refreshURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: Token.self) { [weak self] response in
                guard let self = self else { return }
                switch response.result {
                case .success(let token):
                    self.session = UserSession(token: token, user: session.user)
                    KeychainHelper.standard.save(session,
                                                 service: self.keychainService,
                                                 account: self.keychainAccount)
                case .failure(let error):
                    print("Failed to refresh the JWT: \(error)")
                }
            }
        return false
    }
    
    /**
     Convenience method for Alamofire-based networking.
     Sets the Bearer-Token.
     */
    func getAuthHeaders() -> HTTPHeaders? {
        if !AuthManager.shared.authenticate() {
            return nil
        }
        guard let session = session else { return nil }
        return [.authorization(bearerToken: session.token.accessToken)]
    }
}
