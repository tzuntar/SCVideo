//
//  MSALHelper.swift
//  SCVideo
//

import UIKit
import MSAL

protocol MSALAuthDelegate: UIViewController {
    func didAuthAccount(_ account: MSALAccount)
    func didAuthFailWithError(_ error: Error?)
    func didFetchLoginEntry(_ loginEntry: LoginEntry)
    func didFetchingLoginEntryFailWithError(_ error: Error?)
}

class MSALHelper {

    private class MSALSettings {
        static let kGraphEndpoint = "https://graph.microsoft.com/"
        static let kAuthority = "https://login.microsoftonline.com/scv.si"
        static let kScopes: [String] = ["user.read"]
        static var kClientId: String?
        static var kClientSecret: String?
    }

    private var delegate: MSALAuthDelegate?
    private var applicationContext: MSALPublicClientApplication?
    private var webViewParameters: MSALWebviewParameters?
    private var currentAccount: MSALAccount?
    private var accessToken: String?

    func initMSAL(delegatingActionsTo delegate: MSALAuthDelegate) throws {
        MSALSettings.kClientId = Bundle.main.object(forInfoDictionaryKey: "MSAL_CLIENT_ID") as? String
        MSALSettings.kClientSecret = Bundle.main.object(forInfoDictionaryKey: "MSAL_CLIENT_SECRET") as? String
        guard let authorityURL = URL(string: MSALSettings.kAuthority),
              let clientId = MSALSettings.kClientId else { return }
        self.delegate = delegate
        let authority = try MSALAADAuthority(url: authorityURL)
        let applicationConfig = MSALPublicClientApplicationConfig(clientId: clientId,
                                                               redirectUri: nil,
                                                                 authority: authority)
        applicationContext = try MSALPublicClientApplication(configuration: applicationConfig)
        webViewParameters = MSALWebviewParameters(authPresentationViewController: delegate)
    }

    private func writeLog(_ text: String) {
        print("[MSAL] \(text)")
    }

    func startLoginFromUI() {
        if currentAccount != nil {
            acquireTokenSilently(currentAccount)
        } else {
            acquireTokenInteractively()
        }
    }

    func acquireTokenInteractively() {
        guard let applicationContext = applicationContext else { return }
        guard let webViewParameters = webViewParameters else { return }
        let parameters = MSALInteractiveTokenParameters(scopes: MSALSettings.kScopes, webviewParameters: webViewParameters)
        parameters.promptType = MSALPromptType.selectAccount

        applicationContext.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                self.writeLog("Could not acquire token: \(error)")
                self.delegate?.didAuthFailWithError(error)
                return
            }

            guard let result = result else {
                self.delegate?.didAuthFailWithError(self.reportLocalError(
                        withMessage: "No result returned when acquiring the token",
                        errorCode: nil))
                return
            }

            self.accessToken = result.accessToken
            self.currentAccount = result.account
            self.delegate?.didAuthAccount(result.account)
        }
    }

    func acquireTokenSilently(_ account : MSALAccount!) {
        guard let applicationContext = applicationContext else { return }
        let parameters = MSALSilentTokenParameters(scopes: MSALSettings.kScopes, account: account)
        applicationContext.acquireTokenSilent(with: parameters) { [self] (result, error) in
            if let error = error {
                let nsError = error as NSError

                if (nsError.domain == MSALErrorDomain) {
                    if (nsError.code == MSALError.interactionRequired.rawValue) {   // display the Sign In window
                        DispatchQueue.main.async {
                            acquireTokenInteractively()
                        }
                        return
                    }
                }

                writeLog("Could not acquire token: \(error)")
                return
            }

            guard let result = result else {
                writeLog("No result returned when acquiring the token")
                return
            }

            accessToken = result.accessToken
            currentAccount = result.account
            delegate?.didAuthAccount(result.account)
        }
    }

    private func getGraphEndpoint() -> String {
        MSALSettings.kGraphEndpoint.hasSuffix("/")
                ? (MSALSettings.kGraphEndpoint + "v1.0/me/")
                : (MSALSettings.kGraphEndpoint + "/v1.0/me/");
    }

    func signOutFromUI() {
        guard let applicationContext = applicationContext else { return }
        guard let account = currentAccount else { return }
        do {
            let signOutParams = MSALSignoutParameters(webviewParameters: webViewParameters!)
            if let devMode = getDeviceMode() {
                if devMode == .shared {
                    signOutParams.signoutFromBrowser = true
                }
            } else {
                signOutParams.signoutFromBrowser = false
            }
            applicationContext.signout(with: account, signoutParameters: signOutParams, completionBlock: {(success, error) in
                if let error = error {
                    self.writeLog("Could not sign out account: \(error)")
                    return
                }
                self.accessToken = nil
                self.currentAccount = nil
            })
        }
    }

    func fetchLoginEntry() {
        guard let accessToken = accessToken else { return }
        var request = URLRequest(url: URL(string: getGraphEndpoint())!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        self.delegate?.didFetchingLoginEntryFailWithError(error)
                        return
                    }

                    guard let result = try? JSONSerialization.jsonObject(with: data!, options: []) else {
                        self.writeLog("JSON deserialization failed")
                        self.delegate?.didFetchingLoginEntryFailWithError(nil)
                        return
                    }

                    let data = result as! [String : Any]
                    let username = (data["mail"] as! String).components(separatedBy: "@")[0].lowercased()
                    let loginEntry = LoginEntry(username: username,
                                                password: (data["id"] as! String),
                                                   email: (data["mail"] as! String),
                                               full_name: (data["displayName"] as! String))
                    self.delegate?.didFetchLoginEntry(loginEntry)
                }.resume()
    }

    // MARK: Utility Methods

    private func getDeviceMode() -> MSALDeviceMode? {
        var devMode: MSALDeviceMode?
        if #available(iOS 13.0, *) {
            applicationContext?.getDeviceInformation(with: nil, completionBlock: { (deviceInformation, error) in
                guard let deviceInfo = deviceInformation else { return }
                devMode = deviceInfo.deviceMode
            })
        }
        return devMode
    }

    private func reportLocalError(withMessage message: String, errorCode code: Int?) -> NSError {
        NSError(domain: Bundle.main.bundleIdentifier ?? "local",
                  code: code ?? 1,
              userInfo: [NSLocalizedDescriptionKey: message])
    }

}
