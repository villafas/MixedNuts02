//
//  AddViewController.swift
//  MixedNuts02
//
//  Created by Default User on 3/22/24.
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate {
    
    //MARK: - Properties
    
    // Field Views
    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var courseField: DesignableUITextField!
    @IBOutlet weak var dateTextField: DesignableUITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeField: DesignableUITextField!
    @IBOutlet weak var markWeightField: DesignableUITextField!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let overlayView = UIView()
    
    // Field visibility toggles
    var isNotesFieldVisible = false
    var isMarkWeightFieldVisible = false
    var isCourseDropdownVisible = false
    var isTimeDropdownVisible = false
    var ignoreHideOnScroll = false
    
    // Literals
    var ignoreTime = 0.8
    
    // Field view constraints
    @IBOutlet weak var notesFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var markWeightFieldHeightConstraint: NSLayoutConstraint!
    
    // Field dropdown tables & data
    var courseDropdown: DropdownTableView?
    var courseOptions = ["Loading..."]
    var timeDropdown: DropdownTableView?
    var timePicker = UIDatePicker()
    let timeOptions = ["End of Day", "Start of class", "Custom"]
    
    private let viewModel = AddTaskViewModel()
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind ViewModel to ViewController
        bindViewModel()
    
        datePicker.addTarget(self, action: #selector(datePickerSelected(_:)), for: .editingDidBegin)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        markWeightField.delegate = self
        titleField.delegate = self
        
        configureOverlayView()
        configureCourseDropdown()
        configureTimeDropdown()
        updateAllFieldsVisibility()
        scaleDatePicker(datePicker, within: dateTextField)
        
        hideElementWhenTappedAround()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshCourses()
    }
    
    //MARK: - Add Task
    
    @IBAction func createTaskButtonTapped(_ sender: UIButton) {
        // Gather input from the text fields
        guard let title = titleField.text, !title.isEmpty,
              let course = courseField.text, !course.isEmpty,
              let dueDateStr = dateTextField.text, !dueDateStr.isEmpty,
              let dueTimeStr = timeField.text, !dueTimeStr.isEmpty else {
            print("All fields are required.")
            return
        }
        
        let dueDate = combineDateWithTime(date: datePicker.date, time: timePicker.date)!
        
        // Optional values
        let markWeight = markWeightField.text?.isEmpty == true ? nil : Int(markWeightField.text!)
        let notes = notesView.text?.isEmpty == true ? nil : notesView.text
        
        // Here you can save the course object to your database or use it as needed
        viewModel.addTask(title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight)
    }

    // Function to clear the input fields after adding a course
    func clearAllFields() {
        titleField.text = ""
        courseField.text = ""
        courseDropdown?.deselectAllCells()
        dateTextField.text = ""
        datePicker.date = Date()
        timeField.text = ""
        timePicker.date = Date()
        isMarkWeightFieldVisible = false
        isNotesFieldVisible = false
        updateAllFieldsVisibility()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTaskAdded = { [weak self] in
            DispatchQueue.main.async {
                self?.clearAllFields()
            }
        }
        
        // DELETE
        viewModel.onCoursesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.courseOptions = self!.viewModel.courseList.map { $0.title }
                self?.courseDropdown?.options = self!.courseOptions
                self?.courseDropdown?.tableView.reloadData()
                self?.courseDropdown?.calculateTableHeight()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                // Show error message (e.g., using an alert)
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    //MARK: - Data Reading
    
    func refreshCourses(){
        viewModel.fetchCourses()
    }
    
    //MARK: - Notes toggle
    
    @IBAction func notesToggled(_ sender: Any) {
        // Toggle the field visibility
        isNotesFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.updateNotesFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateNotesFieldVisibility() {
        if isNotesFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            notesFieldHeightConstraint.constant = 250
        } else {
            // Set the height to 0 to hide the form field
            notesView.text = ""
            notesFieldHeightConstraint.constant = 0
        }
    }
    
    //MARK: - Mark Weight Toggle
    
    @IBAction func markWeightToggled(_ sender: Any) {
        // Toggle the field visibility
        isMarkWeightFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.updateMarkWeightFieldVisibility()
            self.view.layoutIfNeeded() // Ensure layout updates immediately
        }
    }
    
    // Update the height constraint based on whether the field is visible
    func updateMarkWeightFieldVisibility() {
        if isMarkWeightFieldVisible {
            // Set the height of the form field (e.g., 100 for a standard height)
            markWeightFieldHeightConstraint.constant = 58
        } else {
            // Set the height to 0 to hide the form field
            markWeightField.text = ""
            markWeightFieldHeightConstraint.constant = 0
        }
    }
    
    //MARK: - Expandables Visibility Handlers
    
    func updateAllFieldsVisibility(){
        updateNotesFieldVisibility()
        updateMarkWeightFieldVisibility()
    }
    
    //MARK: - Dropdown Animations
    
    func showCourseDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            courseDropdown!.alpha = 1
            isCourseDropdownVisible = true
            overlayView.isHidden = false
            //view.layoutIfNeeded()
        }
    }
    
    func hideCourseDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            courseDropdown!.alpha = 0
            isCourseDropdownVisible = false
            overlayView.isHidden = true
            view.layoutIfNeeded()
        }
    }
    
    func showTimeDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            timeDropdown!.alpha = 1
            isTimeDropdownVisible = true
            overlayView.isHidden = false
            //view.layoutIfNeeded()
        }
    }
    
    func hideTimeDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            timeDropdown!.alpha = 0
            isTimeDropdownVisible = false
            overlayView.isHidden = true
            view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Overlay Config
    
    func configureOverlayView(){
        // Setup the overlay view
        overlayView.backgroundColor = UIColor.clear // transparent
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isHidden = true // Initially hidden
        scrollView.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
    
    //MARK: - Dropdown Frame Configs
    
    func setTimeDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = timeField.convert(timeField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        timeDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: timeDropdown!.height!) // Adjust height as needed
    }
    
    func setCourseDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = courseField.convert(courseField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        courseDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: courseDropdown!.height!) // Adjust height as needed
    }
    
    func setCourseDropdownConstraints() {
        // Disable autoresizing mask to use Auto Layout
        courseDropdown?.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove previous constraints if necessary
        NSLayoutConstraint.deactivate(courseDropdown!.constraints)
        
        // Set up the constraints
        NSLayoutConstraint.activate([
            // Align the dropdown's leading edge with the text field's leading edge
            courseDropdown!.leadingAnchor.constraint(equalTo: courseField.leadingAnchor),
            
            // Align the dropdown's trailing edge with the text field's trailing edge
            courseDropdown!.trailingAnchor.constraint(equalTo: courseField.trailingAnchor),
            
            // Position the dropdown's top edge right below the text field
            courseDropdown!.topAnchor.constraint(equalTo: courseField.bottomAnchor, constant: 0),
            
            // Set the height of the dropdown (adjust 132 to your desired height)
            courseDropdown!.heightAnchor.constraint(equalToConstant: 132)
        ])
    }
    
    //MARK: - Dropdown Configs
    func configureCourseDropdown(){
        courseDropdown = DropdownTableView.instanceFromNib(setOptions: courseOptions, maxVisibleRows: 5)
        courseDropdown!.alpha = 0
        courseDropdown!.textField = courseField
        scrollView.addSubview(courseDropdown!)
        
        courseField.delegate = self
    }
    
    func configureTimeDropdown(){
        timeDropdown = DropdownTableView.instanceFromNib(setOptions: timeOptions)
        timeDropdown!.isCustomTimeDropdown = true
        timeDropdown!.timePicker = timePicker
        timeDropdown!.alpha = 0
        timeDropdown!.textField = timeField
        scrollView.addSubview(timeDropdown!)
        
        timeField.delegate = self
    }
    
    func checkVisibleDropdowns() -> Bool {
        if isTimeDropdownVisible == false || isCourseDropdownVisible == false {
            return true
        }
        
        return false
    }
    
    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {  
        toggleScrollIgnore()
        
        if textField == courseField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isCourseDropdownVisible {
                hideCourseDropdown()
            } else {
                setCourseDropdownFrame()
                showCourseDropdown()
            }
        } else if textField == timeField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isTimeDropdownVisible {
                hideTimeDropdown()
            } else {
                setTimeDropdownFrame()
                showTimeDropdown()
            }
        } else if textField == markWeightField{
            overlayView.isHidden = false
        } else {
            overlayView.isHidden = false
        }
    }
    
    // UITextFieldDelegate method to restrict input to numbers
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == markWeightField{
            // Only allow numbers for the numberTextField
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            // Check if the new string is numeric
            let isNumber = allowedCharacters.isSuperset(of: characterSet)
            
            // Get the current text
            let currentText = textField.text ?? ""
            
            // Calculate the new text length after the user input
            let newLength = currentText.count + string.count - range.length
            
            // Limit the input to 3 digits
            return isNumber && newLength <= 3
        } else {
            return true
        }
    }
    
    //MARK: - Text View Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        overlayView.isHidden = false
    }
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This function is called every time the scroll view is scrolled
        if !ignoreHideOnScroll {
            view.endEditing(true)
        }
        if isCourseDropdownVisible{
            hideCourseDropdown()
        }
        
        if isTimeDropdownVisible{
            hideTimeDropdown()
        }
        
        
        if !overlayView.isHidden {
            overlayView.isHidden = true
            
        }
    }
    
    func toggleScrollIgnore(){
        ignoreHideOnScroll = true
        DispatchQueue.main.asyncAfter(deadline: .now() + ignoreTime) {
            self.ignoreHideOnScroll = false
        }
    }
    
    func scrollToTextField(_ textField: UITextField, in scrollView: UIScrollView) {
        // Get the frame of the text field relative to the scroll view
        let textFieldFrame = textField.convert(textField.bounds, to: scrollView)
        
        // Scroll to the text field's frame
        scrollView.scrollRectToVisible(textFieldFrame, animated: true)
    }
    
    //MARK: - Animation Prototype
    
    /*
     @IBAction func courseDropdownToggle(_ sender: UIButton) {
     /*
      UIView.animate(withDuration: 2.0) { //1
      sender.frame = CGRect(x: 0, y: 0, width: -100, height: -100) //2
      sender.center = center //3
      }
      */
     let newButtonWidth: CGFloat = -100
     let center = sender.center
     
     DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
     // This code will run after 0.8 second
     sender.alpha = 0
     }
     
     UIView.animate(withDuration: 2.0) { //1
     sender.frame = CGRect(x: 0, y: 0, width: newButtonWidth, height: newButtonWidth) //2
     sender.center = center //3
     }
     }
     */
    
    //MARK: - DatePicker to Field
    
    @objc func datePickerSelected(_ sender: UIDatePicker){
        dateChanged(sender)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        // Format the date and set it to the text field
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: sender.date)
        //selectedDate = sender.date
    }
    
    func scaleDatePicker(_ datePicker: UIDatePicker, within textField: UITextField) {
        // Get the sizes of the date picker and the text field
        datePicker.contentHorizontalAlignment = .center
        datePicker.clipsToBounds = true
        let datePickerSize = datePicker.bounds.size
        let textFieldSize = textField.bounds.size
        
        // Calculate the scaling factors for width and height
        let scaleWidth = textFieldSize.width / datePickerSize.width
        let scaleHeight = textFieldSize.height / datePickerSize.height
        
        // Apply scaling
        let scaleTransform = CGAffineTransform(scaleX: scaleWidth, y: scaleHeight)
        
        // Apply the transformation to the date picker
        datePicker.transform = scaleTransform
    }
    
    
    //MARK: - Datetime formatting
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        // since date and time fields are seperate, combine them to pass to db
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
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
        //let tapLocation = sender.location(in: self.view)
        
        // Check if the tap was outside the dropdown
        if isCourseDropdownVisible {//} && !courseDropdown!.frame.contains(tapLocation){
            hideCourseDropdown()
        }
        
        if isTimeDropdownVisible {//} && !timeDropdown!.frame.contains(tapLocation){
            hideTimeDropdown()
        }
        
        if !overlayView.isHidden {
            overlayView.isHidden = true
        }
        
        // Hide the keyboard
        view.endEditing(true)
    }
}
