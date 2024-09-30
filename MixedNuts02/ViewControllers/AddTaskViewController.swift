//
//  AddViewController.swift
//  MixedNuts02
//
//  Created by Default User on 3/22/24.
//

import UIKit
import Firebase

class AddTaskViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
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
    
    // Field view constraints
    @IBOutlet weak var notesFieldHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var markWeightFieldHeightConstraint: NSLayoutConstraint!
    
    // Field dropdown tables & data
    var courseDropdown: DropdownTableView?
    let courseOptions = ["test 1", "test 2", "test 3"]
    var timeDropdown: DropdownTableView?
    let timePicker = DesignableDatePicker()
    let timeOptions = ["End of Day", "Start of class", "Custom"]
    
    var db: Firestore!
    var courses: [String] = ["Select a course"]
    var selectedCourse: String?
    var selectedDate: Date?
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        markWeightField.delegate = self
        configureOverlayView()
        configureCourseDropdown()
        configureTimeDropdown()
        updateAllFieldsVisibility()
        scaleDatePicker(datePicker, within: dateTextField)
        
        db = Firestore.firestore()
        hideElementWhenTappedAround()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        getCourses()
    }
    
    //MARK: - Task addition
    @IBAction func submitPressed(_ sender: Any) {
        // if required fields are not empty, add task to db
        /*if let title = titleField.text, let course = courseField.text, !title.isEmpty, !course.isEmpty {
         let dueDate = combineDateWithTime(date: datePicker.date, time: timePicker.date)!
         var task = Task(id: "", title: title, course: course, notes: notesView.text, dueDate: dueDate, markWeight: 0, isComplete: false)
         let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
         var ref: DocumentReference? = nil
         ref = userDbRef.collection("tasks").addDocument(data: task.toAnyObject()) { err in
         if let err = err {
         print("Error adding document: \(err)")
         } else {
         print("Document added with ID: \(ref!.documentID)")
         task.id = ref!.documentID
         self.scheduleNotifications(taskObj: task)
         }
         }
         titleField.text = ""
         courseField.text = ""
         notesView.text = ""
         self.datePicker.date = Date()
         self.timePicker.date = Date()
         }*/
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
            notesFieldHeightConstraint.constant = 150
        } else {
            // Set the height to 0 to hide the form field
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
            view.layoutIfNeeded()
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
            view.layoutIfNeeded()
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
        overlayView.frame = view.bounds
        overlayView.isHidden = true // Initially hidden
        scrollView.addSubview(overlayView)
    }
    
    //MARK: - Dropdown Frame Configs
    
    func setTimeDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = timeField.convert(timeField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        timeDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 132) // Adjust height as needed
    }
    
    func setCourseDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = courseField.convert(courseField.bounds, to: scrollView)
        
        // Set the dropdown's frame to appear right below the text field
        courseDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 132) // Adjust height as needed
    }
    
    //MARK: - Dropdown Configs
    func configureCourseDropdown(){
        courseDropdown = DropdownTableView.instanceFromNib(setOptions: courseOptions, scrollEnabled: false)
        courseDropdown!.alpha = 0
        courseDropdown!.textField = courseField
        scrollView.addSubview(courseDropdown!)
        
        setCourseDropdownFrame()
        
        courseField.delegate = self
    }
    
    func configureTimeDropdown(){
        timeDropdown = DropdownTableView.instanceFromNib(setOptions: timeOptions, scrollEnabled: false)
        timeDropdown!.isCustomTimeDropdown = true
        timeDropdown!.alpha = 0
        timeDropdown!.textField = timeField
        scrollView.addSubview(timeDropdown!)
        
        setTimeDropdownFrame()
        
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
        if textField == courseField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isCourseDropdownVisible {
                hideCourseDropdown()
            } else {
                setCourseDropdownFrame()
                showCourseDropdown()
            }
            //courseDropdownTable.isHidden.toggle()
        }
        
        if textField == timeField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isTimeDropdownVisible {
                hideTimeDropdown()
            } else {
                setTimeDropdownFrame()
                showTimeDropdown()
            }
            //courseDropdownTable.isHidden.toggle()
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
    
    //MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This function is called every time the scroll view is scrolled
        if isCourseDropdownVisible{
            hideCourseDropdown()
        }
        
        if isTimeDropdownVisible{
            hideTimeDropdown()
        }
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
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        // Format the date and set it to the text field
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateTextField.text = dateFormatter.string(from: sender.date)
        selectedDate = sender.date
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
    
    //MARK: - Read courses db
    func getCourses(){
        db.collection("courses").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let course = document.data()["title"] as! String
                    self.courses.append(course)
                }
                //self.coursePicker.reloadComponent(0)
            }
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
        if isCourseDropdownVisible && !courseDropdown!.frame.contains(tapLocation){
            hideCourseDropdown()
        }
        
        if isTimeDropdownVisible && !timeDropdown!.frame.contains(tapLocation){
            hideTimeDropdown()
        }
        
        // Hide the keyboard
        view.endEditing(true)
    }
}
