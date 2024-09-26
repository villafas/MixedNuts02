//
//  CourseScheduleView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-22.
//

import UIKit

class CourseScheduleView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var classroomField: DesignableUITextField!
    @IBOutlet weak var dayField: DesignableUITextField!
    @IBOutlet weak var startTimeTextField: DesignableUITextField!
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeTextField: DesignableUITextField!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var removeButton: UIButton!
    
    var scheduleObj: DaySchedule?
    
    let weekdayDropdownTable = UITableView()
    let weekdayOptions: [DayOfWeek] = DayOfWeek.allCases
    var isWeekdayDropdownVisible = false
    
    
    //MARK: - Data config & formatting/conversion
    func setDelegates(){
        classroomField.delegate = self
        startTimeTextField.delegate = self
        endTimeTextField.delegate = self
        
        scaleDatePicker(startTimePicker, within: startTimeTextField)
        scaleDatePicker(endTimePicker, within: endTimeTextField)
    }
    
    func setFieldValues(){
        classroomField.text = scheduleObj?.classroom ?? ""
        if let schedule = scheduleObj, let day = schedule.day{
            weekdayDropdownTable.selectRow(at: indexPathOfDay(day), animated: false, scrollPosition: .none)
            dayField.text = day.rawValue.capitalized
        }
        
        if let schedule = scheduleObj, let startTime = schedule.startTime{
            startTimePicker.setDate(startTime.toDate()!, animated: true)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            startTimeTextField.text = formatter.string(from: startTime.toDate()!)
        }
        
        if let schedule = scheduleObj, let endTime = schedule.endTime{
            startTimePicker.setDate(endTime.toDate()!, animated: true)
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
    
    //MARK: - Dropdown Configs
    
    func configureCourseDropdown() {
        weekdayDropdownTable.tag = 5
        weekdayDropdownTable.delegate = self
        weekdayDropdownTable.dataSource = self
        weekdayDropdownTable.isHidden = true
        weekdayDropdownTable.layer.borderColor = UIColor.gray.cgColor
        weekdayDropdownTable.layer.borderWidth = 1
        weekdayDropdownTable.rowHeight = 44
        
        weekdayDropdownTable.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        
        self.addSubview(weekdayDropdownTable)
        
        dayField.delegate = self
    }
    
    //MARK: - View instantiation
    class func instanceFromNib(setSchedule: DaySchedule) -> CourseScheduleView{
        let schedule = UINib(nibName: "CourseScheduleView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CourseScheduleView
        schedule.scheduleObj = setSchedule
        schedule.configureCourseDropdown()
        schedule.setDelegates()
        schedule.setFieldValues()
        return schedule
    }
    
    
    //MARK: - Table View Delegate
    
    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekdayOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        
        if tableView.tag == 5 {
            cell.textLabel?.text = weekdayOptions[indexPath.row].rawValue.capitalized
        }
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 5 {
            dayField.text = weekdayOptions[indexPath.row].rawValue.capitalized
            scheduleObj?.day = weekdayOptions[indexPath.row]
            isWeekdayDropdownVisible = false
        }
        
        tableView.isHidden = true
    }
    
    //MARK: - Text Field Delegate
    // UITextFieldDelegate method to detect when the text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dayField {
            // Prevent the keyboard from showing
            textField.resignFirstResponder()
            
            if isWeekdayDropdownVisible {
                weekdayDropdownTable.isHidden = true
                isWeekdayDropdownVisible = false
            } else {
                // Calculate the position of the text field within the view
                let textFieldFrame = textField.convert(textField.bounds, to: self)
                
                // Set the dropdown's frame to appear right below the text field
                weekdayDropdownTable.frame = CGRect(x: textFieldFrame.origin.x, y: textFieldFrame.maxY, width: textFieldFrame.width, height: 120) // Adjust height as needed
                
                weekdayDropdownTable.isHidden = false
                isWeekdayDropdownVisible = true
            }
            //courseDropdownTable.isHidden.toggle()
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

}
