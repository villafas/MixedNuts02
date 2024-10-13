//
//  AddContainerViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-16.
//

import UIKit

class CourseContainerViewController: UIViewController {
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBarBottom: UIView!
    @IBOutlet weak var containerView: UIView!
    
    var timetableVC: TimetableViewController!
    var courseListVC: CourseListViewController!
    var currentVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBarBottom.dropShadow()
        
        // Initialize the child view controllers
        timetableVC = storyboard?.instantiateViewController(withIdentifier: "TimetableViewController") as? TimetableViewController
        courseListVC = storyboard?.instantiateViewController(withIdentifier: "CourseListViewController") as? CourseListViewController
        
        // Set up the initial view (e.g., FirstViewController)
        addChildVC(timetableVC)
        currentVC = timetableVC
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
    
    
    @IBAction func toggleViewIsTapped(_ sender: UIButton) {
        if currentVC == timetableVC {
            // Remove the current view controller and switch to the second one
            removeChildVC(currentVC!)
            addChildVC(courseListVC)
            currentVC = courseListVC
            
            UIView.animate(withDuration: 0.5) { [self] in
                setButtonImage(sender, "table.fill")
                pageTitle.text = "Course List"
                //view.layoutIfNeeded() // Ensure layout updates immediately
            }
        } else {
            // Remove the current view controller and switch back to the first one
            removeChildVC(currentVC!)
            addChildVC(timetableVC)
            currentVC = timetableVC
            
            UIView.animate(withDuration: 0.5) { [self] in
                setButtonImage(sender, "list.bullet")
                pageTitle.text = "TimeTable"
                //view.layoutIfNeeded() // Ensure layout updates immediately
            }
        }
    }
    
    func setButtonImage(_ button: UIButton, _ imageName: String){
        let config = UIImage.SymbolConfiguration(scale: .large)
        if let image = UIImage(systemName: imageName, withConfiguration: config) {
            button.tintColor = UIColor(red: 12.0 / 255, green: 37.0 / 255, blue: 66.0 / 255, alpha: 1.0)
            button.setImage(image, for: .normal)
        }
    }
    
}
