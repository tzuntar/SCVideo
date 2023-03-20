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

    var session: UserSession?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginLogic.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if usernameField.text != nil && passwordField.text != nil {
            loginLogic.attemptLogin(with: LoginEntry(
                    username: usernameField.text!,
                    password: passwordField.text!))
        }
    }

    @IBAction func registerButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "showRegisterSheet", sender: self)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)       // causes the view (or one of its embedded text fields) to resign the first responder status.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showRegisterSheet":
            guard let registerVc = segue.destination as? RegisterController else {
                return
            }
            registerVc.username = usernameField.text
        case "loginToMain":
            guard let swipeVC = segue.destination as? MainSwipeNavigationViewController else { return }
            swipeVC.currentSession = session
        default:
            return
        }
    }

}

extension LoginController: LoginDelegate {

    func didLogInUser(_ session: UserSession) {
        self.session = session
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
