//
//  AddViewController.swift
//  MixedNuts02
//
//  Created by Default User on 3/22/24.
//

import UIKit
import Firebase

class AddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleField: DesignableUITextField!
    @IBOutlet weak var dueDate: DesignableDatePicker!
    @IBOutlet weak var dueTime: DesignableDatePicker!
    @IBOutlet weak var courseField: DesignableUITextField!
    @IBOutlet weak var urlField: DesignableUITextField!
    @IBOutlet weak var notesView: DesignableUITextView!
    @IBOutlet weak var workDate: DesignableDatePicker!
    @IBOutlet weak var workTime: DesignableDatePicker!
    
    var db: Firestore!
    var courses: [String] = ["Select a course"]
    var selectedCourse: String?
    let coursePicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coursePicker.delegate = self
        coursePicker.dataSource = self
        //courseField.inputView = coursePicker
        
        db = Firestore.firestore()
        self.hideKeyboardWhenTappedAround() 
        // Do any additional setup after loading the view.
        
        getCourses()
    }

    //MARK: - Task addition
    @IBAction func submitPressed(_ sender: Any) {
        // if required fields are not empty, add task to db
        if let title = titleField.text, let course = courseField.text, !title.isEmpty, !course.isEmpty {
            let dueDate = combineDateWithTime(date: dueDate.date, time: dueTime.date)!
            let workDate = combineDateWithTime(date: workDate.date, time: workTime.date)!
            var task = Task(id: "", title: title, course: course, taskURL: urlField.text, notes: notesView.text, dueDate: dueDate, workDate: workDate, isComplete: false)
            let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
            var ref: DocumentReference? = nil
            ref = userDbRef.collection("tasks").addDocument(data: task.toAnyObject()) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    task.id = ref!.documentID
                    self.scheduleNotifications(taskObj: task)
                }
            }
            titleField.text = ""
            courseField.text = ""
            urlField.text = ""
            notesView.text = ""
            self.dueDate.date = Date()
            self.dueTime.date = Date()
            self.workDate.date = Date()
            self.workTime.date = Date()
        }
    }
    
    //MARK: - Datetime formatting
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        // since date and time fields are seperate, combine them to pass to db
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
    
    //MARK: - Read courses db
    func getCourses(){
        db.collection("courses").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let course = document.data()["title"] as! String
                    self.courses.append(course)
                }
                self.coursePicker.reloadComponent(0)
            }
        }
    }
    
    //MARK: - Picker view delegate (UNDER DEVELOPMENT)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.courses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            courseField.text = ""
        } else {
            courseField.text = courses[row]
        }
    }
}
