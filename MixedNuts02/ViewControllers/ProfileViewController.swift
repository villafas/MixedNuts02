//
//  ProfileViewController.swift
//  MixedNuts02
//
//  Created by Kevin Yuen on 2024-03-28.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

        // Action that will trigger logging out
    @objc func logoutUser() {
        do {
            try Auth.auth().signOut()
            
            // Optionally: Navigate back to the login screen or another appropriate screen
            self.navigateToLoginScreen()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Optionally: Show an error message to the user
        }
    }
    
    // Function to send the user back to the login page
    func navigateToLoginScreen() {
        if let loginViewController = storyboard?.instantiateViewController(identifier: "LoginViewController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = loginViewController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }

    

}
