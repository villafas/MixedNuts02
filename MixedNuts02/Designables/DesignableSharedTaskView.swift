//
//  DesignableSharedTaskView.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-27.
//

import UIKit

@IBDesignable
class DesignableSharedTaskView: UIView {
    //MARK: - Task View customization
    
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var taskSubtitle: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var viewHeight = 81.0
    
    var taskObj: TaskToDo?
    var friendObj: FriendUser?
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
            didSet {
                layer.cornerRadius = cornerRadius
                clipsToBounds = true
            }
        }
    
    @IBInspectable var bkgColor: UIColor = UIColor.lightGray {
        didSet {
            backgroundColor = bkgColor
        }
    }

    func updateView() {
        
    }
    
    //MARK: - View instantiation
    class func instanceFromNib(setTask: TaskToDo, setFriend: FriendUser) -> DesignableSharedTaskView{
        let task = UINib(nibName: "SharedTaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableSharedTaskView
        task.taskObj = setTask
        task.friendObj = setFriend
        task.taskTitle.text = "\(setTask.title)"
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // dd/MMM
        task.taskSubtitle.text = "\(formatter.string(from: setTask.dueDate)) • \(setTask.course)"
        return task
    }
    
}
