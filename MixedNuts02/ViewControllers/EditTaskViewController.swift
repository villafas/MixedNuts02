//
//  EditTaskViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-07.
//

import UIKit

class EditTaskViewController: AddTaskViewController {

    @IBOutlet weak var navBarBottom: UIView!
    
    var taskObj: Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set drop shadow for navBar
        navBarBottom.dropShadow()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
    }
    
    func setFieldsForTasks(){
        titleField.text = taskObj?.title
        courseField.text = taskObj?.course
        //dateTextField.text =
        if let markWeight = taskObj?.markWeight {
            isMarkWeightFieldVisible = true
            markWeightField.text = "\(markWeight)"
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
    }
    
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        // For view controllers pushed onto the navigation stack
        self.navigationController?.popViewController(animated: true)
    }
}
