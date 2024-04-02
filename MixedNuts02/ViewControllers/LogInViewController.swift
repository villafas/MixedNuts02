//
//  ViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//

import UIKit

class LogInViewController: UIViewController {
    
    @IBOutlet weak var yourButton: UIButton!
    
    //MARK: - Load Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
   }
    
    @IBAction func signInTapped (_ sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }

}

