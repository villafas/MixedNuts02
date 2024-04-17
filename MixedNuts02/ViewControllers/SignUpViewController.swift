//
//  SignUpViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    //IBOutlets
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var confirmPasswordTextField : UITextField!
        

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        passwordTextField.isSecureTextEntry = true
//        confirmPasswordTextField.isSecureTextEntry = true
    }
    
    @IBAction func checkbox_Tapped(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }

    @IBAction func cancel_Tapped(_ sender: UIButton){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    @IBAction func signUpTapped(_ sender: UIButton) {
            // Ensure text fields are not empty
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty,
                  let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
                // Present an alert or handle empty fields appropriately
                return
            }
            
            // Ensure password and confirm password match
            guard password == confirmPassword else {
                // Present an alert or handle mismatched passwords appropriately
                return
            }
            
            // Use Firebase to create a user
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    // Handle errors (e.g., present an alert with the error)
                    print("Failed to create user: \(error.localizedDescription)")
                    return
                }
                
                // On successful sign-up, navigate to the home screen
                DispatchQueue.main.async {
                    self.navigateToHomeScreen()
                }
            }
        }
}
