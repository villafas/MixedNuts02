//
//  CourseScheduleView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-22.
//

import UIKit

class CourseScheduleView: UIView, UITextFieldDelegate {

    @IBOutlet weak var classroomField: DesignableUITextField!
    @IBOutlet weak var dayField: DesignableUITextField!
    @IBOutlet weak var startTimeTextField: DesignableUITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeTextField: DesignableUITextField!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var removeButton: UIButton!
    
    var scheduleObj: DaySchedule?
    
    var weekdayDropdown: DropdownTableView?
    let weekdayOptions: [String] = DayOfWeek.allCases.map { $0.rawValue.capitalized }
    var isWeekdayDropdownVisible = false
    var overlayView: UIView?
    
    var parentScrollView: UIScrollView?
    var parentTapGesture: UITapGestureRecognizer?
    var parentView: UIViewController?
    
    //MARK: - Data config & formatting/conversion
    func setDelegates(){
        classroomField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        scaleDatePicker(startTimePicker, within: startTimeTextField)
        scaleDatePicker(endTimePicker, within: endTimeTextField)
        
        startTimePicker.addTarget(self, action: #selector(timePickerSelected(_:)), for: .editingDidBegin)
        endTimePicker.addTarget(self, action: #selector(timePickerSelected(_:)), for: .editingDidBegin)
    }
    
    func setFieldValues(){
        classroomField.text = scheduleObj?.classroom ?? ""
        if let schedule = scheduleObj, let day = schedule.day{
            weekdayDropdown?.tableView.selectRow(at: indexPathOfDay(day), animated: false, scrollPosition: .none)
            dayField.text = day.rawValue.capitalized
        }
        
        if let schedule = scheduleObj, let startTime = schedule.startTime{
            startTimePicker.setDate(startTime.toDate()!, animated: true)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            startTimeTextField.text = formatter.string(from: startTime.toDate()!)
        }
        
        if let schedule = scheduleObj, let endTime = schedule.endTime{
            endTimePicker.setDate(endTime.toDate()!, animated: true)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            endTimeTextField.text = formatter.string(from: endTime.toDate()!)
        }
    }
    
    func indexPathOfDay(_ day: DayOfWeek) -> IndexPath? {
        if let row = DayOfWeek.allCases.firstIndex(of: day) {
            return IndexPath(row: row, section: 0) // Section can be customized
        }
        return nil
    }
    
    
    //MARK: - Picker to field
    @objc func timePickerSelected(_ sender: UIDatePicker){
        if sender == startTimePicker && startTimeTextField.text == "" {
            timeChanged(sender)
        } else if sender == endTimePicker && endTimeTextField.text == "" {
            timeChanged(sender)
        }
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        // Format the date and set it to the text field
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        if sender == startTimePicker {
            startTimeTextField.text = formatter.string(from: sender.date)
            scheduleObj?.startTime = Time.fromDate(sender.date)
        } else if sender == endTimePicker {
            endTimeTextField.text = formatter.string(from: sender.date)
            scheduleObj?.endTime = Time.fromDate(sender.date)
        }
        //selectedDate = sender.date
    }
    
    //MARK: - Dropdown Frame Configs
    
    func setWeekdayDropdownFrame(){
        // Calculate the position of the text field within the scroll view
        let textFieldFrame = dayField.convert(dayField.bounds, to: parentScrollView)
        
        // Set the dropdown's frame to appear right below the text field
        weekdayDropdown!.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: weekdayDropdown!.height!) // Adjust height as needed
    }
    
    //MARK: - Dropdown Configs
    func configureWeekdayDropdown(){
        weekdayDropdown = DropdownTableView.instanceFromNib(setOptions: weekdayOptions, maxVisibleRows: 5)
        weekdayDropdown!.isCustomDayDropdown = true
        weekdayDropdown!.dayObject = scheduleObj
        weekdayDropdown!.textField = dayField
        weekdayDropdown!.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.weekdayDropdown!.isHidden = false
            self.weekdayDropdown!.alpha = 0
        }
        parentScrollView!.addSubview(weekdayDropdown!)
        weekdayDropdown!.tag = 5
        
        dayField.delegate = self
    }
    
    //MARK: - Dropdown Animations
    
    func showWeekdayDropdown(){
        UIView.animate(withDuration: 0.1){ [self] in
            weekdayDropdown!.alpha = 1
            isWeekdayDropdownVisible = true
            overlayView!.isHidden = false
            self.layoutIfNeeded()
        }
    }
    
    func hideWeekdayDropdown(){
        if weekdayDropdown == nil {
            return
        }
        
        UIView.animate(withDuration: 0.1){ [self] in
            weekdayDropdown!.alpha = 0
            isWeekdayDropdownVisible = false
            overlayView!.isHidden = true
            self.layoutIfNeeded()
        }
    }

    //MARK: - View instantiation
    class func instanceFromNib(setSchedule: DaySchedule, parentScrollView: UIScrollView, parentOverlayView: UIView, parentView: UIViewController, parentTapGesture: UITapGestureRecognizer) -> CourseScheduleView{
        let schedule = UINib(nibName: "CourseScheduleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CourseScheduleView
        schedule.parentScrollView = parentScrollView
        schedule.overlayView = parentOverlayView
        schedule.parentTapGesture = parentTapGesture
        schedule.parentView = parentView
        schedule.scheduleObj = setSchedule
        schedule.configureWeekdayDropdown()
        schedule.hideElementWhenTappedAround()
        schedule.setDelegates()
        schedule.setFieldValues()
        return schedule
    }
    
    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let parentView = parentView as? AddCourseViewController{
            parentView.toggleScrollIgnore()
        }
        
        if textField == dayField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isWeekdayDropdownVisible {
                hideWeekdayDropdown()
            } else {
                setWeekdayDropdownFrame()
                showWeekdayDropdown()
            }
            //courseDropdownTable.isHidden.toggle()
        } else {
            overlayView!.isHidden = false
        }
    }
    
    // Text field delegate method to update model
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == classroomField {
            scheduleObj!.classroom = textField.text
        }
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
    
    //MARK: - Tap Dismiss
    
    func hideElementWhenTappedAround() {
        // Add a single tap gesture recognizer to hide both the dropdown and the keyboard
        let tapGesture = parentTapGesture
        tapGesture?.addTarget(self, action: #selector(handleTapOutside(_:)))
    }
    
    
    // Handle tap outside to hide both dropdown and keyboard
    @objc func handleTapOutside(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: parentView!.view)
        
        // Hide the keyboard
        parentView!.view.endEditing(true)
        
        // Check if the tap was outside the dropdown
        if isWeekdayDropdownVisible{//} && !weekdayDropdown!.frame.contains(tapLocation){
            hideWeekdayDropdown()
        }
        
        if !overlayView!.isHidden {
            overlayView!.isHidden = true
        }
        
    }

}
