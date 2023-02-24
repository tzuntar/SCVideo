//
//  RegistrationLogic.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 10/22/22.
//

import Foundation
import Alamofire

protocol RegistrationDelegate {
    func didRegisterUser(_ session: UserSession)
    func didRegistrationFailWithError(_ error: Error)
}

struct RegistrationEntry: Encodable {
    let name: String
    let username: String
    let phone: String
    let password: String
}

enum RegistrationError: Error, CustomStringConvertible {
    case dataMissing
    case databaseSaveFailed
    case unexpected(code: Int)

    public var description: String {
        switch self {
        case .databaseSaveFailed:
            return "Shranjevanje podatkov spodletelo"
        case .dataMissing:
            return "Prosimo, vnesite vse podatke"
        case .unexpected(_):
            return "Napaka"
        }
    }
}


class RegistrationLogic {

    var delegate: RegistrationDelegate?

    func attemptRegistration(with regEntry: RegistrationEntry) {
        AF.request(APIURL + "/auth/register",
                        method: .post,
                        parameters: regEntry,
                        encoder: JSONParameterEncoder.default)
                .validate()
                .responseDecodable(of: UserSession.self) { response in
                    if let safeResponse = response.value {
                        self.delegate?.didRegisterUser(safeResponse)
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
            self.delegate?.didRegistrationFailWithError(RegistrationError.databaseSaveFailed)
        case 400:
            self.delegate?.didRegistrationFailWithError(RegistrationError.dataMissing)
        default:
            self.delegate?.didRegistrationFailWithError(RegistrationError.unexpected(
                    code: responseCode))
        }
    }

}
