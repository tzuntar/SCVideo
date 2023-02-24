//
//  LoginController.swift
//  SCVideo
//
//  Created by Tobija Žuntar on 9/29/22.
//

import UIKit

class RegisterController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!

    var username: String?
    let registrationLogic = RegistrationLogic()

    var session: UserSession?

    override func viewDidLoad() {
        super.viewDidLoad()
        registrationLogic.delegate = self;
        if let safeUsername = username {
            usernameField.text = safeUsername
        }
    }

    @IBAction func backArrowPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func createAccountPressed(_ sender: UIButton) {
        guard let name = nameField.text, name.count > 0 else { return }
        guard let username = usernameField.text, username.count > 0 else { return }
        guard let phone = phoneField.text, phone.count > 0 else { return }
        guard let password = passwordField.text, password.count > 0 else { return }
        guard let confirmPassword = confirmPasswordField.text,
              confirmPassword.count > 0 else { return }
        if password != confirmPassword {
            return; // todo: alert that the passwords don't match
        }

        registrationLogic.attemptRegistration(with: RegistrationEntry(
                name: name,
                username: username,
                phone: phone,
                password: password))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationToMain" {
            if let safeSession = session {
                guard let mainTabVC = segue.destination as? MainTabBarController else {
                    return
                }
                mainTabVC.session = safeSession
            }
        }
    }
}

extension RegisterController: RegistrationDelegate {

    func didRegisterUser(_ session: UserSession) {
        self.session = session
        performSegue(withIdentifier: "registrationToMain", sender: self)
    }

    func didRegistrationFailWithError(_ error: Error) {
        if let error = error as? RegistrationError {
            WarningAlert().showWarning(withTitle: "Napaka",
                                       withDescription: error.description)
        } else {
            WarningAlert().showWarning(withTitle: "Napaka",
                                       withDescription: error.localizedDescription)
        }
    }


}
