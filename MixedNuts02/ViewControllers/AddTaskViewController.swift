//
//  AddViewController.swift
//  MixedNuts02
//
//  Created by Default User on 3/22/24.
//

import UIKit
import Firebase

class AddTaskViewController: BaseScrollViewController, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var navBarBottom: UIView!
    
    // Field Views
    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var courseField: DesignableUITextField!
    @IBOutlet weak var dateTextField: DesignableUITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeField: DesignableUITextField!
    @IBOutlet weak var markWeightField: DesignableUITextField!
    @IBOutlet weak var markWeightButton: UIButton!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var notesButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var threeDayToggle: UISwitch!
    @IBOutlet weak var oneDayToggle: UISwitch!
    @IBOutlet weak var twelveHourToggle: UISwitch!
    @IBOutlet weak var oneHourToggle: UISwitch!
    
    
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
    
    internal let viewModel = AddTaskViewModel()
    
    var isEditMode: Bool = false
    var taskObj: TaskToDo?
    var onDismiss: ((String?) -> Void)?  // Closure to notify MainViewController
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Bind ViewModel to ViewController
        bindViewModel()
        
        navBarBottom.dropShadow()
        
        datePicker.addTarget(self, action: #selector(datePickerSelected(_:)), for: .editingDidBegin)
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        markWeightField.delegate = self
        titleField.delegate = self
        notesView.delegate = self
        
        configureOverlayView()
        configureCourseDropdown()
        configureTimeDropdown()
        updateAllFieldsVisibility()
        scaleDatePicker(datePicker, within: dateTextField)
        
        hideElementWhenTappedAround()
        // Do any additional setup after loading the view.
        
        scrollView.delegate = self
        
        self.baseScrollView = scrollView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshCourses()
        setEditingMode()
    }
    
    //MARK: - Add Task
    
    @IBAction func createTaskButtonTapped(_ sender: UIButton) {
        // Gather input from the text fields
        guard let title = titleField.text, !title.isEmpty,
              let course = courseField.text, !course.isEmpty,
              let dueDateStr = dateTextField.text, !dueDateStr.isEmpty,
              let dueTimeStr = timeField.text, !dueTimeStr.isEmpty else {
            showAlert(title: "Missing Fields", message: "Please ensure you have entered a Title, Course, and Due Date for your Task.")
            return
        }
        
        let dueDate = combineDateWithTime(date: datePicker.date, time: timePicker.date)!
        
        // Optional values
        let markWeight = markWeightField.text?.isEmpty == true ? nil : Int(markWeightField.text!)
        let notes = notesView.text?.isEmpty == true ? nil : notesView.text
        
        viewModel.notifIntervals = []
        
        // Reminders
        if threeDayToggle.isOn {
            viewModel.notifIntervals?.append(TimeInterval(-3*24*60*60))
        }
        if oneDayToggle.isOn {
            viewModel.notifIntervals?.append(TimeInterval(-1*24*60*60))
        }
        if twelveHourToggle.isOn {
            viewModel.notifIntervals?.append(TimeInterval(-12*60*60))
        }
        if oneHourToggle.isOn {
            viewModel.notifIntervals?.append(TimeInterval(-1*60*60))
        }
        
        if isEditMode {
            taskObj = TaskToDo(id: taskObj!.id, title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight, isComplete: taskObj!.isComplete)
            
            updateTask()
        } else {
            viewModel.addTask(title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight)
        }
        
        dismissView()
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
        timeDropdown?.deselectAllCells()
        timeDropdown?.selectedIndex = nil
        updateClassTime()
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
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        // DELETE
        viewModel.onCoursesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.courseOptions = self!.viewModel.courseList.map { $0.title }
                self?.courseDropdown?.options = self!.courseOptions
                self?.courseDropdown?.tableView.reloadData()
                self?.courseDropdown?.calculateTableHeight()
                if self!.isEditMode {
                    self?.selectCourseDropdownRow()
                    self?.setTimeDropdown()
                }
            }
        }
        
        // Handle UI Updates on changes to data
        viewModel.onTaskUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.clearAllFields()
                self?.navigationController?.popViewController(animated: true)
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
    
    //MARK: - Dismiss Closure
    
    func dismissView() {
        dismiss(animated: true) { [weak self] in
            // Call the closure to notify MainViewController
            self?.onDismiss?(self!.viewModel.newID)
        }
    }
    
    
    //MARK: - Data Reading
    func refreshCourses(){
        viewModel.fetchCourses()
    }
    
    func updateTask(){
        viewModel.updateTask(task: taskObj!)
    }
    
    //MARK: - Editing Mode Config
    
    func setEditingMode(){
        if isEditMode{
            pageTitle.text = "Edit Task"
            setFieldsForTasks()
            updateAllFieldsVisibility()
            initialButtonConfig()
        }
    }
    
    func setFieldsForTasks(){
        titleField.text = taskObj?.title
        courseField.text = taskObj?.course
        
        if let dueDate = taskObj?.dueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateTextField.text = dateFormatter.string(from: dueDate)
            datePicker.date = dueDate
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let timeText = timeFormatter.string(from: dueDate)
            timeField.text = timeText
        }
        
        if let markWeight = taskObj?.markWeight, markWeight != 0 {
            isMarkWeightFieldVisible = true
            markWeightField.text = "\(markWeight)"
        }
        
        if let notes = taskObj?.notes, !notes.isEmpty {
            isNotesFieldVisible = true
            notesView.text = notes
        }
        
        if let taskId = taskObj?.id {
            let idStrings: [String] = ["\(taskId)_3D", "\(taskId)_1D", "\(taskId)_12H", "\(taskId)_1H"]
            NotificationHelper.findNotifications(withIDs: idStrings) { foundIDs in
                DispatchQueue.main.async{
                    if !foundIDs.isEmpty {
                        if foundIDs.contains(idStrings[0]){
                            self.threeDayToggle.setOn(true, animated: true)
                        }
                        if foundIDs.contains(idStrings[1]){
                            self.oneDayToggle.setOn(true, animated: true)
                        }
                        if foundIDs.contains(idStrings[2]){
                            self.twelveHourToggle.setOn(true, animated: true)
                        }
                        if foundIDs.contains(idStrings[3]){
                            self.oneHourToggle.setOn(true, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Notes toggle
    
    @IBAction func notesToggled(_ sender: UIButton) {
        // Toggle the field visibility
        isNotesFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.toggleButtonImage(sender, self.isNotesFieldVisible)
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
    
    @IBAction func markWeightToggled(_ sender: UIButton) {
        // Toggle the field visibility
        isMarkWeightFieldVisible.toggle()
        
        // Animate the height change
        UIView.animate(withDuration: 0.3) {
            self.toggleButtonImage(sender, self.isMarkWeightFieldVisible)
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
    
    func toggleButtonImage(_ button: UIButton, _ state: Bool){
        if state == false {
            let config = UIImage.SymbolConfiguration(scale: .large)
            if let image = UIImage(systemName: "plus.circle", withConfiguration: config) {
                button.setImage(image, for: .normal)
            }
        } else {
            let config = UIImage.SymbolConfiguration(scale: .large)
            if let image = UIImage(systemName: "minus.circle", withConfiguration: config) {
                button.setImage(image, for: .normal)
            }
        }
    }
    
    func initialButtonConfig(){
        toggleButtonImage(notesButton, isNotesFieldVisible)
        toggleButtonImage(markWeightButton, isMarkWeightFieldVisible)
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
    
    //MARK: - Dropdown selections
    
    func setTimeDropdown(){
        if let dueDate = taskObj?.dueDate {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let timeText = timeFormatter.string(from: dueDate)
            timeField.text = timeText
            timePicker.date = dueDate
            updateClassTime()
            
            if checkEndOfDayTime(compareTo: timeText){
                selectTimeDropdownRow(row: 0)
            } else if checkClassTime(compareTo: timeText){
                selectTimeDropdownRow(row: 1)
            } else {
                selectTimeDropdownRow(row: 2)
            }
        }
    }
    
    func selectTimeDropdownRow(row: Int){
        let selectedIndex = IndexPath(row: row, section: 0)
        timeDropdown?.selectedIndex = selectedIndex
        timeDropdown?.tableView.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
    }
    
    func selectCourseDropdownRow(){
        if let index = courseDropdown?.options.firstIndex(of: courseField.text ?? "") {
            courseDropdown?.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .none)
        }
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
                updateClassTime()
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
        toggleScrollIgnore()
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
        if dateTextField.text == "" {
            dateChanged(sender)
        }
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
    
    func updateClassTime(){
        if let selectedCourse = viewModel.courseList.first(where: { $0.title == courseField.text}),
           let matchingSchedule = selectedCourse.schedule.first(where: { $0.day?.rawValue.capitalized == getDayOfWeek(from: datePicker.date) }){
            timeDropdown?.classTime = convertTimeToDate(time: matchingSchedule.startTime!)!
        } else {
            timeDropdown?.classTime = nil
        }
        
        timeDropdown?.tableView.reloadData()
        timeDropdown?.tableView.selectRow(at: timeDropdown?.selectedIndex, animated: false, scrollPosition: .none)
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
    
    func getDayOfWeek(from date: Date) -> String {
        let calendar = Calendar.current
        let weekdayIndex = calendar.component(.weekday, from: date)
        return calendar.weekdaySymbols[weekdayIndex - 1] // Convert index to get the day name
    }
    
    func convertTimeToDate(time: Time, for date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        
        // Get the year, month, and day components from the given date
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Set the hour and minute from the Time struct
        components.hour = time.hour
        components.minute = time.minute
        
        // Convert the components back to a Date object
        return calendar.date(from: components)
    }
    
    //MARK: - Time Comparisons
    
    func checkClassTime(compareTo: String) -> Bool{
        if let classTime = timeDropdown?.classTime {
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            let classTimeText = timeFormatter.string(from: classTime)
            if compareTo == classTimeText {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func checkEndOfDayTime(compareTo: String) -> Bool{
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        // Create DateComponents for 11:59 PM
        var components = DateComponents()
        components.hour = 23 // 24-hour format for 11 PM
        components.minute = 59
        
        // Use the current calendar to create a Date object
        let calendar = Calendar.current
        if let time = calendar.date(from: components) {
            let endOfDayTimeText = timeFormatter.string(from: time)
            if compareTo == endOfDayTimeText {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add a default OK action
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present the alert on the current view controller
        self.present(alert, animated: true, completion: nil)
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
