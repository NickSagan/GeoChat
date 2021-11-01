//
//  LoginViewController.swift
//  GeoChat
//
//  Created by Nick Sagan on 01.11.2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        title = K.appName
    }

    @IBAction func loginPressed(_ sender: UIButton) {

        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                if let e = error{
                    print(e)
                    self?.errorLabel.text = e.localizedDescription
                } else{
                    self?.performSegue(withIdentifier: K.loginSegue, sender: self)
                }
            }
        }
    }
}
