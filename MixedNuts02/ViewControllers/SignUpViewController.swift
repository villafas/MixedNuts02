//
//  SignUpViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func signUpTapped (_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
            
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
}
