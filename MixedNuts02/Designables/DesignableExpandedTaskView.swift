//
//  DesignableEditTaskView.swift
//  MixedNuts02
//
//  Created by Default User on 3/25/24.
//

import UIKit

@IBDesignable
class DesignableExpandedTaskView: DesignableTaskView {
    //MARK: - Expanded task view customization
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var markWeightField: DesignableUITextField!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var editButton: DesignableUIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: - Expanded task view instantiation
    override class func instanceFromNib(setTask: Task) -> DesignableExpandedTaskView{
        let task = UINib(nibName: "ExpandedTaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableExpandedTaskView
        task.taskObj = setTask
        task.taskTitle.text = "\(setTask.title)"
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        task.taskSubtitle.text = "\(formatter.string(from: setTask.dueDate)) • \(setTask.course)"
        if task.taskObj?.isComplete == true {
            task.taskIsDone()
        } else {
            task.taskIsNotDone()
        }
        //task.markWeightField.delegate = task.self
        //task.notesView.delegate = task.self
        //task.urlField.text = task.taskObj?.taskURL
        task.markWeightField.text = "\(task.taskObj?.markWeight ?? 0)"
        task.notesView.text = task.taskObj?.notes
        return task
    }
}
