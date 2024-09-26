//
//  AddCourseViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-16.
//

import UIKit

class AddCourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //MARK: - Properties
    
    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var codeField: DesignableUITextField!
    @IBOutlet weak var termField: DesignableUITextField!
    @IBOutlet weak var scheduleTable: SelfSizedTableView!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scheduleButton: UIButton!
    
    // Constraints
    @IBOutlet weak var urlFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var additionalScheduleFieldHeightConstraint: NSLayoutConstraint!
    
    // Visibility bools
    var isAdditionalFieldVisible = false
    var isUrlFieldVisible = false
    var isTermDropdownVisible = false
    
    // Dropdown properties
    let termDropdownTable = UITableView()
    let termOptions = ["Fall 2024", "Winter 2025", "Spring 2025"]
    
    var scheduleList: [DaySchedule]!
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scheduleList = [DaySchedule]()
        scheduleTable.delegate = self
        scheduleTable.dataSource = self

        configureTermDropdown()
        updateAllFieldsVisibility()
        
        hideElementWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - Dropdown Configs
    
    func configureTermDropdown() {
        termDropdownTable.tag = 7
        termDropdownTable.delegate = self
        termDropdownTable.dataSource = self
        termDropdownTable.isHidden = true
        termDropdownTable.layer.cornerRadius = 20
        termDropdownTable.layer.borderColor = UIColor.gray.cgColor
        termDropdownTable.layer.borderWidth = 1
        termDropdownTable.rowHeight = 44
        
        termDropdownTable.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        
        scrollView.addSubview(termDropdownTable)
        
        termField.delegate = self
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
            additionalScheduleFieldHeightConstraint.constant = 0
            scheduleButton.alpha = 1
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
    
    func updateAllFieldsVisibility(){
        
        updateAdditionalFieldVisibility()
        updateUrlFieldVisibility()
    }
    
    //MARK: - Schedule handling
    @IBAction func addSchedulePressed(_ sender: Any) {
        scheduleList.append(DaySchedule())
        UIView.animate(withDuration: 0.3) {
            self.scheduleTable.reloadData()
            if self.scheduleList!.count == 1 {
                self.additionalToggled()
            }
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    @IBAction func removeSchedulePressed(_ sender: UIButton){
        if let scheduleView = sender.superview?.superview?.superview?.superview?.superview as? CourseScheduleView, let index = scheduleList!.firstIndex(where: { $0 == scheduleView.scheduleObj }) {
            scheduleList.remove(at: index)
            
        }
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.scheduleTable.reloadData()
            if self.scheduleList!.count == 0 {
                self.additionalToggled()
            }
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == termDropdownTable {
            return termOptions.count
        }
        
        return scheduleList!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == termDropdownTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
            
            if tableView.tag == 7 {
                cell.textLabel?.text = termOptions[indexPath.row]
            }
            
            return cell
        }
        // else
        let cell = tableView.dequeueReusableCell(withIdentifier: "schedule", for: indexPath)
        if let viewWithTag = cell.contentView.viewWithTag(80) {
                viewWithTag.removeFromSuperview()
        }
        
        let scheduleView = CourseScheduleView.instanceFromNib(setSchedule: scheduleList![indexPath.row])
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        scheduleView.heightAnchor.constraint(equalToConstant: 227).isActive = true
        scheduleView.widthAnchor.constraint(equalToConstant: scheduleTable.frame.width).isActive = true
        scheduleView.tag = 80
        
        scheduleView.removeButton.addTarget(self, action: #selector(removeSchedulePressed(_:)), for: .touchUpInside)
        
        cell.contentView.addSubview(scheduleView)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == termDropdownTable {
            return 44
        }
        
        return 227.0
    }
    
    
    // UITableViewDelegate method to handle selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 7 {
            termField.text = termOptions[indexPath.row]
            isTermDropdownVisible = false
        }
        
        tableView.isHidden = true
    }
    

    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == termField{
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isTermDropdownVisible {
                termDropdownTable.isHidden = true
                isTermDropdownVisible = false
            } else {
                // Calculate the position of the text field within the scroll view
                let textFieldFrame = textField.convert(textField.bounds, to: scrollView)
                
                // Set the dropdown's frame to appear right below the text field
                termDropdownTable.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 120) // Adjust height as needed
                
                termDropdownTable.isHidden = false
                isTermDropdownVisible = true
            }
            //courseDropdownTable.isHidden.toggle()
        }
    }
    
    //MARK: - Tap Dismiss
    
    func hideElementWhenTappedAround() {
        // Add a single tap gesture recognizer to hide both the dropdown and the keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false // Let other touches work normally
        self.view.addGestureRecognizer(tapGesture)
    }
    
    
    // Handle tap outside to hide both dropdown and keyboard
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.view)
        
        // Check if the tap was outside the dropdown
        if isTermDropdownVisible && !termDropdownTable.frame.contains(tapLocation){
            termDropdownTable.isHidden = true
            isTermDropdownVisible = false
        }
        
        // Hide the keyboard
        view.endEditing(true)
    }
    
    

}
