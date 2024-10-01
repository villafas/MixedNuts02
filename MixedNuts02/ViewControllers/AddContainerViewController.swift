//
//  AddContainerViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-16.
//

import UIKit

class AddContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var navBarTitle: UILabel!
    
    var addTaskVC: AddTaskViewController!
    var addCourseVC: AddCourseViewController!
    var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the child view controllers
        addTaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController
        addCourseVC = storyboard?.instantiateViewController(withIdentifier: "AddCourseViewController") as? AddCourseViewController
        
        // Set up the initial view (e.g., FirstViewController)
        addChildVC(addTaskVC)
        currentVC = addTaskVC
    }
    
    func addChildVC(_ childVC: UIViewController) {
        // Add the child view controller
        addChild(childVC)
        containerView.addSubview(childVC.view)
        
        // Set up constraints for the child view controller
        childVC.view.frame = containerView.bounds
        childVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childVC.didMove(toParent: self)
    }
    
    func removeChildVC(_ childVC: UIViewController) {
        // Remove the child view controller
        childVC.willMove(toParent: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParent()
    }
    
    
    @IBAction func toggleViewIsTapped(_ sender: Any) {
        if currentVC == addTaskVC {
            // Remove the current view controller and switch to the second one
            removeChildVC(currentVC!)
            addChildVC(addCourseVC)
            currentVC = addCourseVC
            
            UIView.animate(withDuration: 0.5) { [self] in
                navBarTitle.text = "Add Course"
                //view.layoutIfNeeded() // Ensure layout updates immediately
            }
        } else {
            // Remove the current view controller and switch back to the first one
            removeChildVC(currentVC!)
            addChildVC(addTaskVC)
            currentVC = addTaskVC
            
            UIView.animate(withDuration: 0.5) { [self] in
                navBarTitle.text = "Add Task"
                //view.layoutIfNeeded() // Ensure layout updates immediately
            }
        }
    }
    
}
