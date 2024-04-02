//
//  DesignableEditTaskView.swift
//  MixedNuts02
//
//  Created by Default User on 3/25/24.
//

import UIKit

@IBDesignable
class DesignableExpandedTaskView: DesignableTaskView, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var urlButton: DesignableUIButton!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var saveButton: DesignableUIButton!
    
    override class func instanceFromNib(setTask: Task) -> DesignableExpandedTaskView{
        let task = UINib(nibName: "ExpandedTaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DesignableExpandedTaskView
        task.taskObj = setTask
        task.taskTitle.text = "\(setTask.title) \(setTask.course)"
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a, dd/MMM"
        task.taskDate.text = "\(formatter.string(from: setTask.dueDate))"
        if task.taskObj?.isComplete == true {
            task.taskIsDone()
        } else {
            task.taskIsNotDone()
        }
        task.urlField.delegate = task.self
        task.notesView.delegate = task.self
        task.urlField.text = task.taskObj?.taskURL
        task.notesView.text = task.taskObj?.notes
        return task
    }
    
    @IBAction func goToUrl(_ sender: Any) {
        if let url = URL(string: (taskObj?.taskURL)!) {
               UIApplication.shared.open(url)
            }
    }
    
    @IBAction func updateAction(_ sender: UITextField){
        //updateButtons()
    }
    
    func updateButtons(urlText: String){
        if urlText == taskObj?.taskURL && notesView.text == taskObj?.notes{
            saveButton.setDisabled()
        } else {
            saveButton.setEnabled()
        }
        
        if taskObj?.taskURL == "" || taskObj?.taskURL != urlText{
            urlButton.setDisabled()
        } else {
            urlButton.setEnabled()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateButtons(urlText: urlField.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // text hasn't changed yet, you have to compute the text AFTER the edit yourself
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        // do whatever you need with this updated string (your code)
        updateButtons(urlText: updatedString!)
        
        // always return true so that changes propagate
        return true
    }
}
