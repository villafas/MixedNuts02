//
//  SignUpViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit
import Firebase


class SignUpViewController: UIViewController {
    
    //IBOutlets
    @IBOutlet var nameTextField : UITextField!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var confirmPasswordTextField : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Buttons logic
    
    @IBAction func checkbox_Tapped(_ sender: UIButton){
        // Checkbox toggle logic
        if sender.isSelected {
            sender.isSelected = false
        } else {
            sender.isSelected = true
        }
    }
    
    @IBAction func cancel_Tapped(_ sender: UIButton){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Create user
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
            
            guard let user = authResult?.user else {
                print("Failed to get user data after creation.")
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = nameTextField.text
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating display name:", error.localizedDescription)
                    return
                }
                // Display name updated successfully
                // Now, you can proceed with adding user data to the Firebase Database
                // Set user information globally
                AppUser.shared.setUser(uid: user.uid, displayName: user.displayName, email: user.email)
            }
            
            let db = Firestore.firestore()
            
            // Create a table for the user that matches the uid
            let ref = db.collection("users").document(user.uid)
            ref.setData([:]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(user.uid)")
                }
            }
            
            // On successful sign-up, navigate to the home screen
            DispatchQueue.main.async {
                self.navigateToHomeScreen()
            }
        }
    }
}
