//
//  AddCourseViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-16.
//

import UIKit

class AddCourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var codeField: DesignableUITextField!
    @IBOutlet weak var termField: DesignableUITextField!
    @IBOutlet weak var scheduleTable: SelfSizedTableView!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scheduleButton: UIButton!
    var tapGesture: UITapGestureRecognizer?
    
    let overlayView = UIView()
    
    // Visibility bools
    var isAdditionalFieldVisible = false
    var isUrlFieldVisible = false
    var isInstructorFieldVisible = false
    var isTermDropdownVisible = false
    
    // Constraints
    @IBOutlet weak var urlFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var instructorFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalScheduleFieldHeightConstraint: NSLayoutConstraint!
    
    // Dropdown properties
    var termDropdown: DropdownTableView?
    let termOptions = ["Fall 2024", "Winter 2025", "Spring 2025"]
    
    var scheduleList: [DaySchedule]!
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleList = [DaySchedule]()
        scheduleTable.delegate = self
        scheduleTable.dataSource = self
        configureOverlayView()
        configureTermDropdown()
        updateAllFieldsVisibility()
        scrollView.delegate = self
        
        hideElementWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: - Overlay Config
    
    func configureOverlayView(){
        // Setup the overlay view
        overlayView.backgroundColor = UIColor.clear // transparent
        overlayView.frame = view.bounds
        overlayView.isHidden = true // Initially hidden
        scrollView.addSubview(overlayView)
    }
    
    
    //MARK: - Dropdown Frame Configs
    
    func setTermDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = termField.convert(termField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        termDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 132) // Adjust height as needed
    }
    
    
    //MARK: - Dropdown Configs
    func configureTermDropdown(){
        termDropdown = DropdownTableView.instanceFromNib(setOptions: termOptions, scrollEnabled: true)
        termDropdown!.alpha = 0
        termDropdown!.textField = termField
        scrollView.addSubview(termDropdown!)
        
        setTermDropdownFrame()
        
        termField.delegate = self
    }
    
    //MARK: - Dropdown Animations
    
    func showTermDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            termDropdown!.alpha = 1
            isTermDropdownVisible = true
            overlayView.isHidden = false
            view.layoutIfNeeded()
        }
    }
    
    func hideTermDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            termDropdown!.alpha = 0
            isTermDropdownVisible = false
            overlayView.isHidden = true
            view.layoutIfNeeded()
        }
    }
    
    //MARK: - Field Toggles
    
    @IBAction func urlToggled(_ sender: Any) {
        // Toggle the field visibility
        isUrlFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.updateUrlFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    @IBAction func instructorToggled(_ sender: Any) {
        // Toggle the field visibility
        isInstructorFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.updateInstructorFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    func additionalToggled() {
        // Toggle the field visibility
        isAdditionalFieldVisible.toggle()
        updateAdditionalFieldVisibility()
    }
    
    //MARK: - Visibility toggles
    
    // Update the height constraint based on whether the field is visible
    func updateAdditionalFieldVisibility() {
        if isAdditionalFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            additionalScheduleFieldHeightConstraint.constant = 40
            scheduleButton.alpha = 0
        } else {
            // Set the height to 0 to hide the form field
            scheduleButton.alpha = 1
            additionalScheduleFieldHeightConstraint.constant = 0
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateUrlFieldVisibility() {
        if isUrlFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            urlFieldHeightConstraint.constant = 58
        } else {
            // Set the height to 0 to hide the form field
            urlFieldHeightConstraint.constant = 0
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateInstructorFieldVisibility() {
        if isInstructorFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            instructorFieldHeightConstraint.constant = 58
        } else {
            // Set the height to 0 to hide the form field
            instructorFieldHeightConstraint.constant = 0
        }
    }
    
    func updateAllFieldsVisibility(){
        updateInstructorFieldVisibility()
        updateAdditionalFieldVisibility()
        updateUrlFieldVisibility()
    }
    
    //MARK: - Schedule handling
    @IBAction func addSchedulePressed(_ sender: Any) {
        scheduleList.append(DaySchedule())
        UIView.animate(withDuration: 0.2, animations: {
            // First animation block
            if self.scheduleList!.count == 1 {
                self.additionalToggled()
            }
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Second animation block after the first completes
            UIView.animate(withDuration: 0.3) {
                self.scheduleTable.reloadData()
                self.view.layoutIfNeeded()
            }
        })
    }
    
    @IBAction func removeSchedulePressed(_ sender: UIButton){
        if let scheduleView = sender.superview?.superview?.superview?.superview?.superview as? CourseScheduleView, let index = scheduleList!.firstIndex(where: { $0 == scheduleView.scheduleObj }) {
            scheduleList.remove(at: index)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            // First animation block
            self.scheduleTable.reloadData()
            self.view.layoutIfNeeded()
        }, completion: { _ in
            // Second animation block after the first completes
            UIView.animate(withDuration: 0.2) {
                if self.scheduleList!.count == 0 {
                    self.additionalToggled()
                }
                self.view.layoutIfNeeded()
            }
        })
    }
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scheduleList!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "schedule", for: indexPath)
        if let viewWithTag = cell.contentView.viewWithTag(80) {
            viewWithTag.removeFromSuperview()
        }
        
        let scheduleView = CourseScheduleView.instanceFromNib(setSchedule: scheduleList![indexPath.row], parentScrollView: scrollView, parentOverlayView: overlayView, parentView: self, parentTapGesture: tapGesture!)
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleView.heightAnchor.constraint(equalToConstant: 227).isActive = true
        scheduleView.widthAnchor.constraint(equalToConstant: scheduleTable.frame.width).isActive = true
        scheduleView.tag = 80
        
        scheduleView.removeButton.addTarget(self, action: #selector(removeSchedulePressed(_:)), for: .touchUpInside)
        
        cell.contentView.addSubview(scheduleView)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 227.0
    }
    
    
    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == termField{
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isTermDropdownVisible {
                hideTermDropdown()
            } else {
                setTermDropdownFrame()
                showTermDropdown()
            }
        }
    }
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This function is called every time the scroll view is scrolled
        if isTermDropdownVisible{
            hideTermDropdown()
        }
        for row in 0..<scheduleTable.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            
            if let cell = scheduleTable.cellForRow(at: indexPath) {
                let scheduleView = cell.viewWithTag(80) as? CourseScheduleView
                scheduleView?.hideWeekdayDropdown()
            }
        }
    }
    
    //MARK: - Tap Dismiss
    
    func hideElementWhenTappedAround() {
        // Add a single tap gesture recognizer to hide both the dropdown and the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false // Let other touches work normally
        self.view.addGestureRecognizer(tapGesture)
        //self.tapGesture = tapGesture
    }
    
    
    // Handle tap outside to hide both dropdown and keyboard
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.view)
        
        // Check if the tap was outside the dropdown
        if isTermDropdownVisible && !termDropdown!.frame.contains(tapLocation){
            hideTermDropdown()
        }
        
        // Hide the keyboard
        view.endEditing(true)
    }
    
    
    
}
