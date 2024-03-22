//
//  HomeViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//
//https://www.youtube.com/watch?v=XwXEsKRYUXU
//https://medium.com/@didoaint/scratching-the-firebase-services-with-your-ios-app-c2746881c6d8
    
import UIKit
import EventKit
import Firebase

@IBDesignable
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var calendarViewBox: UIView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBInspectable var decorationColor: UIColor!
    @IBInspectable var tintColor: UIColor!
    
    var db: Firestore!
    
    var taskList = [Task]()
    var dateList = [Date]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendarView()
        //taskTable.translatesAutoresizingMaskIntoConstraints = false
        
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        
        db = Firestore.firestore()
        
        var dateList = [Date]()
        db.collection("tasks").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDate = ((document.data()["workDate"]) as! Timestamp).dateValue();
                    dateList.append(taskDate.removeTimeStamp!)
                }
                self.dateList = dateList
            }
        }
    }
    
    
    
    private func configureCalendarView(){
        let calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.tintColor = tintColor
        calendarViewBox.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarViewBox.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewBox.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: calendarViewBox.centerXAnchor)
        ])
        
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        calendarView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        if let viewWithTag = cell.contentView.viewWithTag(100) {
                viewWithTag.removeFromSuperview()
        }
        let taskView = DesignableTaskView.instanceFromNib()
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.taskTitle.text = taskList[indexPath.row].title
        taskView.taskDate.text = "Lol"
        taskView.tag = 100
        cell.contentView.addSubview(taskView)
        return cell
    }
}

extension HomeViewController: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        //print(dateComponents)
        // HARD CODED
//        var day = dateComponents!.day
//        if day == 15 {
//            createTask("ICE 14 ICE 14 Advanced Java Frameworks", "7:00PM, 15/March")
//            createTask("Assignment 2 iOS Development", "11:59PM, 15/March")
//            createTask("Quiz 5 Software Management", "11:59PM, 15/March")
//            subtitleLabel.text = "You have 3 tasks for the day"
//
//        } else {
//            taskStackView.arrangedSubviews.forEach{(element) in
//                if element is DesignableTaskView{
//                    taskStackView.removeArrangedSubview(element)
//                    element.removeFromSuperview()
//                }
//            }
//            subtitleLabel.text = "You have 5 remaining tasks for this week"
//        }
        
        // MAIN LOGIC
        // Go through all of the tasks in the table, and position them on the right day
        db.collection("tasks").whereField("dueDate", isDateEqual: dateComponents!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var taskList = [Task]()
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    taskList.append(task)
                }
                self.taskList = taskList
                self.taskTable.reloadData();
            }
        }
    }
}

extension HomeViewController: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        //let font = UIFont(name:"Poppins-Regular", size: 14)
        //Save the dates
        if dateList.isEmpty {
            return nil
        }
        
        guard let day = Calendar.current.date(from: dateComponents)?.removeTimeStamp else {
            return nil
        }

        for date in dateList{
            if date == day {
                return UICalendarView.Decoration.default(color: decorationColor, size: .small)
            }
        }

        return nil
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    public var removeTimeStamp : Date? {
       guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
        return nil
       }
       return date
   }
}

extension CollectionReference {
    func whereField(_ field: String, isDateEqual value: DateComponents) -> Query {
        //let components = Calendar.current.dateComponents([.year, .month, .day], from: value)
        guard
            let start = Calendar.current.date(from: value),
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        else {
            fatalError("Could not find start date or calculate end date.")
        }
        return whereField(field, isGreaterThan: start).whereField(field, isLessThan: end)
    }
}
