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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showRegisterSheet":
            guard let registerVc = segue.destination as? RegisterController else {
                return
            }
            registerVc.username = usernameField.text
        case "loginToMain":
            if let safeSession = session {
                guard let mainTabVC = segue.destination as? MainTabBarController else { return }
                mainTabVC.session = safeSession
            }
        case "loginToFeed":
            guard let feedVC = segue.destination as? FeedViewController else { return }
            feedVC.currentSession = session
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
