//
//  SocialViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import UIKit

class SocialViewController: UIViewController {

    @IBOutlet weak var navBarBottom: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navBarBottom.dropShadow()
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
            // Dismiss the current view controller
            navigationController?.popViewController(animated: true)
        }

}
