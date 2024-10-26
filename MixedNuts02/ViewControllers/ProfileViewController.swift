//
//  ProfileViewController.swift
//  MixedNuts02
//
//  Created by Kevin Yuen on 2024-03-28.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: - Properties
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    //@IBOutlet weak var programBox: UIView!
    //@IBOutlet weak var socialBox: UIView!
    //@IBOutlet weak var summaryBox: UIView!
    @IBOutlet weak var navBarBottom: UIView!
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBarBottom.dropShadow()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabels()
    }
    
    //MARK: - UI Methods
    
    func updateLabels(){
        nameLabel.text = ("\(AppUser.shared.firstName ?? "User") \(AppUser.shared.lastName ?? "Name")")
        usernameLabel.text = AppUser.shared.displayName
    }
}
