//
//  ManageViewController.swift
//  Milestone2
//
//  Created by Default User on 3/16/24.
//

import UIKit

class ManageViewController: UIViewController {

    @IBOutlet var completeBtn: UIButton!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var popupDeleteView: UIView!
    @IBOutlet var popupDoneView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupDeleteView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        popupDoneView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func showDeleteAction(_ sender: Any) {
            animateScaleIn(desiredView: popupDeleteView)
        }
        
    @IBAction func doneDeleteAction(_ sender: Any) {
            animateScaleOut(desiredView: popupDeleteView)
        }
    
    @IBAction func showDoneAction(_ sender: Any) {
            animateScaleIn(desiredView: popupDoneView)
        }
        
    @IBAction func doneDoneAction(_ sender: Any) {
            animateScaleOut(desiredView: popupDoneView)
        }
    
        
    /// Animates a view to scale in and display
    func animateScaleIn(desiredView: UIView) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        desiredView.center = backgroundView.center
        desiredView.isHidden = false
        
        desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        desiredView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
//            desiredView.transform = CGAffineTransform.identity
        }
    }
    
    /// Animates a view to scale out remove from the display
    func animateScaleOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            desiredView.alpha = 0
        }, completion: { (success: Bool) in
            desiredView.removeFromSuperview()
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            
        }, completion: { _ in
            
        })
    }

}
