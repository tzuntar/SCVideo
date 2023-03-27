//
//  LoginController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 9/29/22.
//

import UIKit

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
            try msalHelper.initMSAL(forViewController: self)
        } catch {
            print("Failed: \(error)")
        }
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        /*if usernameField.text != nil && passwordField.text != nil {
            loginLogic.attemptLogin(with: LoginEntry(
                    username: usernameField.text!,
                    password: passwordField.text!))
        }*/
        msalHelper.startLoginFromUI()
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegisterSheet", sender: self)
    }

}

extension LoginController: LoginDelegate {

    func didLogInUser(_ session: UserSession) {
        AuthManager.shared.startSession(session)
        self.performSegue(withIdentifier: "loginToMain", sender: self)
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
