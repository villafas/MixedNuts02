//
//  ViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit
import FirebaseAuth

class LogInViewController: BaseScrollViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: - Load Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.baseScrollView = scrollView
        
        hideKeyboardWhenTappedAround()
   }
    
//    MARK: - Sign in without login auth
//    @IBAction func signInTapped (_ sender: UIButton){
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
//        // This is to get the SceneDelegate object from your view controller
//        // then call the change root view controller function to change to main tab bar
//        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
//
//        //sampleNotification()
//    }
    
    //MARK: - Sign in user
    // Sign In Action
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text,
                !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            presentAlert(title: "Missing Information", message: "Please fill out all fields.")
            return
        }
        
        // Perform Sign in
        Auth.auth().signIn(withEmail: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.presentAlert(title: "Sign In Failed", message: error.localizedDescription)
            } else {
                guard let user = authResult?.user else {
                    print("Failed to get user data.")
                    return
                }
                
                // Set user information globally
                AppUser.shared.setUser(uid: user.uid, displayName: user.displayName, email: user.email)
            }
        }
    }
    
    // Sign Up Action
//    @IBAction func signUpTapped(_ sender: AnyObject) {
//        // Assuming you have a SignUpViewController you want to present
//        if let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") {
//            navigationController?.pushViewController(signUpVC, animated: true)
//        }
//    }
    
    //MARK: - Alert
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}


