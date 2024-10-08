//
//  DesignableEditTaskView.swift
//  MixedNuts02
//
//  Created by Default User on 3/25/24.
//

import UIKit

@IBDesignable
class DesignableExpandedTaskView: DesignableTaskView, UITextViewDelegate, UITextFieldDelegate {
    //MARK: - Expanded task view customization
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var markWeightField: DesignableUITextField!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var editButton: DesignableUIButton!
    
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
    
    //MARK: - URL Navigation
    @IBAction func goToUrl(_ sender: Any) {
        if let url = URL(string: ("")) {
               UIApplication.shared.open(url)
            }
    }
    
    @IBAction func updateAction(_ sender: UITextField){
        //updateButtons()
    }
    
    //MARK: - Button toggling
    /*
    func updateButtons(urlText: String){
        if urlText == "" && notesView.text == taskObj?.notes{
            saveButton.setDisabled()
        } else {
            saveButton.setEnabled()
        }
        
        if "" == "" || "" != urlText{
            urlButton.setDisabled()
        } else {
            urlButton.setEnabled()
        }
    }
    */
    
    func textViewDidChange(_ textView: UITextView) {
        //updateButtons(urlText: urlField.text!)
    }
    
    //MARK: - Text field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // text hasn't changed yet, you have to compute the text AFTER the edit yourself
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)

        // do whatever you need with this updated string
        //updateButtons(urlText: updatedString!)
        
        // always return true so that changes propagate
        return true
    }
}
