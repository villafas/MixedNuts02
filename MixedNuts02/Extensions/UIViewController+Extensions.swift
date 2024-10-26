//
//  UIViewController+Extensions.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation
import UIKit

// Put this piece of code anywhere you like
extension UIViewController {
    // allow keyboards to be tapped out of
    
    //MARK: - Keyboard dismissal
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func navigateToHomeScreen() {
        if let mainTabBarController = storyboard?.instantiateViewController(identifier: "MainTabBarController") {
            //            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            //               let sceneDelegate = windowScene.delegate as? SceneDelegate {
            //                sceneDelegate.window?.rootViewController = mainTabBarController
            //                sceneDelegate.window?.makeKeyAndVisible()
            //            }
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
        }
    }
    
    //MARK: - Alert
    func showViewControllerAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a default OK action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert on the current view controller
        self.present(alert, animated: true, completion: nil)
    }
}
