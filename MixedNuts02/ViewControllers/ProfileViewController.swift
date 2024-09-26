//
//  ProfileViewController.swift
//  MixedNuts02
//
//  Created by Kevin Yuen on 2024-03-28.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set profile info
        nameLabel.text = AppUser.shared.displayName
        emailLabel.text = AppUser.shared.email
        
    }
    
    //MARK: - Delete account logic
    
    @IBAction func deleteIsPressed(_ sender: Any) {
        presentAlert(title: "Account Deletion", message: "Are you sure you want to delete your account? This action cannot be reversed.")
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
            // Call your function when confirm is pressed
            if let user = Auth.auth().currentUser {
                // Delete the user's account
                user.delete { error in
                    if let error = error {
                        // An error occurred while deleting the account
                        print("Error deleting user account: \(error.localizedDescription)")
                    } else {
                        // Account deleted successfully
                        print("User account deleted successfully.")
                        self.navigateToLoginScreen()
                    }
                }
            } else {
                // User is not authenticated or not signed in
                print("User is not authenticated or not signed in.")
            }
        }
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    //MARK: - Logout logic
    
    
    // New Logout function with confirmation alert
    @IBAction func logoutIsPress(_ sender: Any) {
        // Create an alert controller
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        // Add the "Confirm" action
        let confirmAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            // If the user confirms, perform the logout
            do {
                try Auth.auth().signOut()
                AppUser.shared.clearUser()
                // Optionally: Navigate back to the login screen or another appropriate screen
                self.navigateToLoginScreen()
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
                // Optionally: Show an error message to the user
            }
        }
        
        // Add the "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add both actions to the alert
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        self.present(alert, animated: true, completion: nil)
    }

    // Action that will trigger logging out
    @IBAction func logoutIsPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            AppUser.shared.clearUser()
            // Optionally: Navigate back to the login screen or another appropriate screen
            self.navigateToLoginScreen()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            // Optionally: Show an error message to the user
        }
    }
    
    //MARK: - Navigation
    // Function to send the user back to the login page
    func navigateToLoginScreen() {
        if let loginViewController = storyboard?.instantiateViewController(identifier: "LoginNavigationController") {
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//               let sceneDelegate = windowScene.delegate as? SceneDelegate {
//                sceneDelegate.window?.rootViewController = loginViewController
//                sceneDelegate.window?.makeKeyAndVisible()
//            }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginViewController)
        }
    }

    

}
