//
//  DesignableExpandedSharedTaskView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-27.
//

import UIKit

@IBDesignable
class DesignableExpandedSharedTaskView: DesignableSharedTaskView {
    //MARK: - Expanded task view customization
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var markWeightField: DesignableUITextField!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    //MARK: - Expanded task view instantiation
    override class func instanceFromNib(setTask: Task, setFriend: FriendUser) -> DesignableExpandedSharedTaskView{
        let task = UINib(nibName: "ExpandedSharedTaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableExpandedSharedTaskView
        task.taskObj = setTask
        task.friendObj = setFriend
        task.taskTitle.text = "\(setTask.title)"
        task.usernameLabel.text = "\(task.friendObj?.username ?? "No Username")"
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        task.taskSubtitle.text = "\(formatter.string(from: setTask.dueDate)) • \(setTask.course)"
        task.markWeightField.text = "\(task.taskObj?.markWeight ?? 0)"
        task.notesView.text = task.taskObj?.notes
        return task
    }
}

