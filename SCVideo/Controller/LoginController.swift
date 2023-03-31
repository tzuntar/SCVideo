//
//  LoginController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 9/29/22.
//

import UIKit
import MSAL

class LoginController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    let loginLogic = LoginLogic()
    var msalHelper = MSALHelper()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        loginLogic.delegate = self
        do {
            try msalHelper.initMSAL(delegatingActionsTo: self)
        } catch {
            print("Failed: \(error)")
        }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
//        if usernameField.text != nil && passwordField.text != nil {
//            loginLogic.attemptLogin(with: LoginEntry(
//                    username: usernameField.text!,
//                    password: passwordField.text!))
//        } else {
            msalHelper.startLoginFromUI()
//        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegisterSheet", sender: self)
    }

}

extension LoginController: MSALAuthDelegate {

        func didAuthAccount(_ account: MSALAccount) {
            loginLogic.attemptAdLogin(with: LoginEntry(username: account.username!,
                                                       password: account.identifier!,
                                                       email: "account.email",
                                                       full_name: "account.name"))
        }

        func didAuthFailWithError(_ error: Error?) {
            WarningAlert().showWarning(withTitle: "Napaka", withDescription: "Prišlo je do neznane napake pri prijavi.")
            print("[MSAL] Failed to authenticate account: \(error?.localizedDescription ?? "Unknown error")")
        }

}

extension LoginController: LoginDelegate {

    func didLogInUser(_ session: UserSession) {
        AuthManager.shared.startSession(session)
        performSegue(withIdentifier: "loginToMain", sender: self)
    }

    func didLoginFailWithError(_ error: Error) {
        if let error = error as? LoginError {
            WarningAlert().showWarning(withTitle: "Napaka",
                                       withDescription: error.description)
        } else {
            WarningAlert().showWarning(withTitle: "Napaka",
                                       withDescription: error.localizedDescription)
        }
    }

}
