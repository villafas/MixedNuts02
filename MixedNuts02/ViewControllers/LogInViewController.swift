import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check if a user is logged in
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("\(user.email!) is logged in.")
                self.navigateToHomeScreen()
            } else {
                print("There is no active user.")
            }
        }
    }
    
    // Sign In Action
    @IBAction func signInTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            presentAlert(title: "Missing Information", message: "Please fill out all fields.")
            return
        }
        
        // Perform Sign in
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.presentAlert(title: "Sign In Failed", message: error.localizedDescription)
            } else {
                strongSelf.navigateToHomeScreen()
            }
        }
    }
    
    // Sign Up Action
    @IBAction func signUpTapped(_ sender: AnyObject) {
        // Assuming you have a SignUpViewController you want to present
        if let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") {
            navigationController?.pushViewController(signUpVC, animated: true)
        }
    }

    func navigateToHomeScreen() {
        if let mainTabBarController = storyboard?.instantiateViewController(identifier: "MainTabBarController") {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = mainTabBarController
                sceneDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
