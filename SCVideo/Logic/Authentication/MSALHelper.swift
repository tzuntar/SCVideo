//
//  MSALHelper.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 3/27/23.
//

import Foundation
import MSAL

class MSALHelper {
    
    private class MSALSettings {
        static let kGraphEndpoint = "https://graph.microsoft.com/"
        static let kAuthority = "https://login.microsoftonline.com/common"
        static let kScopes: [String] = ["user.read"]
        static let kClientId: String? = Bundle.main.object(forInfoDictionaryKey: "MSAL_CLIENT_SECRET")
        static let kClientSecret: String? = Bundle.main.object(forInfoDictionaryKey: "MSAL_CLIENT_SECRET")
    }
    
    var accessToken = String()
    var applicationContext: MSALPublicClientApplication?
    var webViewParameters: MSALWebviewParameters?
    var currentAccount: MSALAccount?
    
    static func initMSAL() {
        guard let authorityURL = URL(string: MSALSettings.kAuthority) else {
            self.updateLogging(text: "Unable to create authority URL")
            return
        }

        let authority = try MSALAADAuthority(url: MSALSettings.kAuthority)

        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: MSALSettings.kClientId,
                                                                  redirectUri: nil,
                                                                  authority: authority)
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration)
        
        // FIXME: this goes somewhere else
        self.initWebViewParams()
    }
    
    static func initiateMSALSignIn() {
        let parameters = MSALInteractiveTokenParameters(scopes: MSALSettings.kScopes,
                                                        webviewParameters: self.webViewParamaters!)
        self.applicationContext!.acquireToken(with: parameters) { (result, error) in /* Add your handling logic */}
    }
    
    static func silentlyAcquireMSALToken() {
        self.applicationContext!.getCurrentAccount(with: nil) { (currentAccount, previousAccount, error) in
            guard let account = currentAccount else { return }
            let silentParams = MSALSilentTokenParameters(scopes: MSALSettings.kScopes, account: account)
            self.applicationContext!.acquireTokenSilent(with: silentParams) { (result, error) in
                /* Add your handling logic */
            }
        }
    }
    
    // FIXME: this goes somewhere else
    static func initWebViewParams() {
        self.webViewParameters = MSALWebviewParameters(authPresentationViewController: self)
    }
    
}
