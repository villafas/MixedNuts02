//
//  AddViewController.swift
//  MixedNuts02
//
//  Created by Default User on 3/22/24.
//

import UIKit
import Firebase

class AddViewController: UIViewController {

    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var dueDate: DesignableDatePicker!
    @IBOutlet weak var dueTime: DesignableDatePicker!
    @IBOutlet weak var courseField: DesignableUITextField!
    @IBOutlet weak var workDate: DesignableDatePicker!
    @IBOutlet weak var workTime: DesignableDatePicker!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()

        // Do any additional setup after loading the view.
    }

    @IBAction func submitPressed(_ sender: Any) {
        if let title = titleField.text, let course = courseField.text, !title.isEmpty, !course.isEmpty {
            let dueDate = combineDateWithTime(date: dueDate.date, time: dueTime.date)!
            let workDate = combineDateWithTime(date: workDate.date, time: workTime.date)!
            var task = Task(title: title, course: course, dueDate: dueDate, workDate: workDate, isComplete: false)
            var ref: DocumentReference? = nil
            ref = db.collection("tasks").addDocument(data: task.toAnyObject()) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
            }
        }
    }
    
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = NSCalendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)

        var mergedComponments = DateComponents()
        mergedComponments.year = dateComponents.year!
        mergedComponments.month = dateComponents.month!
        mergedComponments.day = dateComponents.day!
        mergedComponments.hour = timeComponents.hour!
        mergedComponments.minute = timeComponents.minute!
        mergedComponments.second = timeComponents.second!
        
        return calendar.date(from: mergedComponments)
    }
}
