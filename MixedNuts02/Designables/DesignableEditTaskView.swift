//
//  DesignableEditTaskView.swift
//  MixedNuts02
//
//  Created by Default User on 3/25/24.
//

import UIKit

@IBDesignable
class DesignableEditTaskView: DesignableTaskView {
    //MARK: - Edit task view customization
    @IBOutlet weak var deleteButton: UIButton!
    
    //MARK: - Edit task view instantiation
    override class func instanceFromNib(setTask: TaskToDo) -> DesignableEditTaskView{
        let task = UINib(nibName: "EditTaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableEditTaskView
        task.taskObj = setTask
        task.taskTitle.text = "\(setTask.title) • \(setTask.course)"
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, dd/MMM"
        task.taskSubtitle.text = "\(formatter.string(from: setTask.dueDate))"
        if task.taskObj?.isComplete == true {
            task.taskIsDone()
        } else {
            task.taskIsNotDone()
        }
        return task
    }
}
