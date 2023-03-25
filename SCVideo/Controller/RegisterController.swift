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

    let registrationLogic = RegistrationLogic()

    override func viewDidLoad() {
        super.viewDidLoad()
        registrationLogic.delegate = self;
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

}

extension RegisterController: RegistrationDelegate {

    func didRegisterUser(_ session: UserSession) {
        AuthManager.shared.startSession(session)
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
