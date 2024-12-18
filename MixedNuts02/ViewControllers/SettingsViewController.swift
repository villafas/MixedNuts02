//
//  SettingsViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    @IBOutlet weak var navBarBottom: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBarBottom.dropShadow()
    }
    
    //MARK: - Delete account logic
    
    @IBAction func deleteIsPressed(_ sender: Any) {
        presentDeleteAlert(title: "Account Deletion", message: "Are you sure you want to delete your account? This action cannot be reversed.")
    }
    
    private func presentDeleteAlert(title: String, message: String) {
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
    
    private func presentLogoutAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .destructive) { _ in
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
        
        alert.addAction(confirmAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true)
    }
    
    // Action that will trigger logging out
    @IBAction func logoutIsPressed(_ sender: Any) {
        presentLogoutAlert(title: "Log Out", message: "Are you sure you want to log out?")
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
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
            // Dismiss the current view controller
            navigationController?.popViewController(animated: true)
        }

}
