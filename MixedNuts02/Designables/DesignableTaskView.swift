//
//  DesignableUIView.swift
//  Milestone2
//
//  Created by Default User on 3/15/24.
//

import UIKit

@IBDesignable
class DesignableTaskView: UIView {
    //MARK: - Task View customization
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskSubtitle: UILabel!
    @IBOutlet weak var taskButton: UIButton!
    var viewHeight = 81.0
    
    var taskObj: Task?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
        }
    }
    
    @IBInspectable var doneColor: UIColor = UIColor.lightGray {
        didSet{
        }
    }

    func updateView() {
        
    }
    
    func taskIsDone(){
        taskButton.isSelected = true
        backgroundColor = doneColor
    }
    
    func taskIsNotDone(){
        taskButton.isSelected = false
        backgroundColor = bkgColor
    }
    
    //MARK: - View instantiation
    class func instanceFromNib(setTask: Task) -> DesignableTaskView{
        let task = UINib(nibName: "TaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableTaskView
        task.taskObj = setTask
        task.taskTitle.text = "\(setTask.title)"
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // dd/MMM
        task.taskSubtitle.text = "\(formatter.string(from: setTask.dueDate)) • \(setTask.course)"
        if task.taskObj?.isComplete == true {
            task.taskIsDone()
        } else {
            task.taskIsNotDone()
        }
        return task
    }

    
    
    
}
