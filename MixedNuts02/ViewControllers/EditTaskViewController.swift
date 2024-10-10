//
//  EditTaskViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-07.
//

import UIKit

class EditTaskViewController: AddTaskViewController {

    //MARK: - Properties
    
    @IBOutlet weak var navBarBottom: UIView!
    
    var taskObj: Task?
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindEditViewModel()
        // Set drop shadow for navBar
        navBarBottom.dropShadow()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setFieldsForTasks()
        updateAllFieldsVisibility()
    }
    
    //MARK: - Model & Controller Binding
    
    private func bindEditViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onCoursesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.courseOptions = self!.viewModel.courseList.map { $0.title }
                self?.courseDropdown?.options = self!.courseOptions
                self?.courseDropdown?.tableView.reloadData()
                self?.courseDropdown?.calculateTableHeight()
                self?.selectCourseDropdownRow()
                self?.setTimeDropdown()
            }
        }
        
        // Handle UI Updates on changes to data
        viewModel.onTaskUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.clearAllFields()
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    //MARK: - Field Updating
    
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
    
    //MARK: - Data reading
    func updateTask(){
        viewModel.updateTask(task: taskObj!)
    }
    
    //MARK: - Button actions
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        // For view controllers pushed onto the navigation stack
        clearAllFields()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
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
        
        taskObj = Task(id: taskObj!.id, title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight, isComplete: taskObj!.isComplete)
        
        updateTask()
    }
}
