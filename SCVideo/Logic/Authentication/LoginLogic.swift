//
//  LoginLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/12/22.
//

import Foundation
import Alamofire

protocol LoginDelegate {
    func didLogInUser(_ session: UserSession)
    func didLoginFailWithError(_ error: Error)
}

struct LoginEntry: Encodable {
    let username: String
    let password: String
}

enum LoginError: Error, CustomStringConvertible {
    case invalidCredentials
    case serverSideError
    case dataMissing
    case unexpected(code: Int)

    public var description: String {
        switch self {
        case .invalidCredentials:
            return "Neveljavno uporabniško ime ali geslo"
        case .serverSideError:
            return "Prijava spodletela"
        case .dataMissing:
            return "Prosimo, vnesite vse podatke"
        case .unexpected(_):
            return "Neznana napaka"
        }
    }
}

class LoginLogic {

    var delegate: LoginDelegate?

    func attemptLogin(with loginEntry: LoginEntry) {
        AF.request(APIURL + "/auth/login",
                        method: .post,
                        parameters: loginEntry,
                        encoder: JSONParameterEncoder.default)
                .validate()
                .responseDecodable(of: UserSession.self) { response in
                    if let safeResponse = response.value {
                        self.delegate?.didLogInUser(safeResponse)
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
            self.delegate?.didLoginFailWithError(LoginError.serverSideError)
        case 401:
            self.delegate?.didLoginFailWithError(LoginError.invalidCredentials)
        default:
            self.delegate?.didLoginFailWithError(LoginError.unexpected(
                    code: responseCode))
        }
    }

}
