//
//  SignUpViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit
import Firebase

class SignUpViewController: BaseScrollViewController {
    
    //IBOutlets
    @IBOutlet var firstNameTextField : UITextField!
    @IBOutlet var lastNameTextField : UITextField!
    @IBOutlet var usernameTextField : UITextField!
    @IBOutlet var emailTextField : UITextField!
    @IBOutlet var passwordTextField : UITextField!
    @IBOutlet var confirmPasswordTextField : UITextField!
    @IBOutlet var scrollView : UIScrollView!
    
    var acceptedTerms: Bool = false
    
    private let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        
        self.baseScrollView = scrollView
        
        hideKeyboardWhenTappedAround()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onSignUp = { [weak self] in
            DispatchQueue.main.async {
                self?.createUser()
            }
        }
        
        viewModel.onTakenUsername = { [weak self] in
            DispatchQueue.main.async {
                self?.showViewControllerAlert(title: "Username Taken", message: "This username is alredy taken, please try a different one.")
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                // Show error message (e.g., using an alert)
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    //MARK: - Data Reading
    
    func checkUsername(_ username: String){
        viewModel.checkUsername(username)
    }
    
    //MARK: - Buttons logic
    
    @IBAction func checkbox_Tapped(_ sender: UIButton){
        // Checkbox toggle logic
        if sender.isSelected {
            sender.isSelected = false
            acceptedTerms = false
        } else {
            sender.isSelected = true
            acceptedTerms = true
        }
    }
    
    @IBAction func cancel_Tapped(_ sender: UIButton){
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Create user
    @IBAction func signUpTapped(_ sender: UIButton) {
        // Ensure text fields are not empty
        guard let email = emailTextField.text,
              !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let firstName = firstNameTextField.text,
              !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let lastName = lastNameTextField.text,
              !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let username = usernameTextField.text,
              !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty
        else {
            // Present an alert or handle empty fields appropriately
            showViewControllerAlert(title: "Missing Fields", message: "Please fill out all of the fields.")
            return
        }
        
        if !isValidUsername(username.trimmingCharacters(in: .whitespacesAndNewlines)) {
            showViewControllerAlert(title: "Invalid Username", message: "This username contains invalid characters. Please use letters, numbers, and underscores only.")
            return
        }
        
        // Ensure password and confirm password match
        guard password == confirmPassword else {
            // Present an alert or handle mismatched passwords appropriately
            showViewControllerAlert(title: "Password Mismatch", message: "The passwords do not match, please try again.")
            return
        }
        
        if !acceptedTerms {
            showViewControllerAlert(title: "Terms And Conditions", message: "Please accept the terms and conditions.")
            return
        }
        
        checkUsername(username.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func createUser(){
        let email = emailTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        // Use Firebase to create a user
        Auth.auth().createUser(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                // Handle errors (e.g., present an alert with the error)
                showViewControllerAlert(title: "Failed to Create User", message: "\(error.localizedDescription)")
                return
            }
            
            guard let user = authResult?.user else {
                print("Failed to get user data after creation.")
                return
            }
            
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Error updating display name:", error.localizedDescription)
                    return
                }
                // Display name updated successfully
                // Now, you can proceed with adding user data to the Firebase Database
                // Set user information globally
                AppUser.shared.setUser(uid: user.uid, displayName: user.displayName, email: user.email, firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines), lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            let db = Firestore.firestore()
            
            // Create a table for the user that matches the uid
            let ref = db.collection("users").document(user.uid)
            ref.setData([
                "firstName": firstName.trimmingCharacters(in: .whitespacesAndNewlines),
                "lastName": lastName.trimmingCharacters(in: .whitespacesAndNewlines),
                "username": username.trimmingCharacters(in: .whitespacesAndNewlines)
            ]) { err in
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
    
    func isValidUsername(_ username: String) -> Bool {
        let regex = "^[a-zA-Z0-9_]+$"  // Allows letters, numbers, and underscores only
        return username.range(of: regex, options: .regularExpression) != nil
    }
}
