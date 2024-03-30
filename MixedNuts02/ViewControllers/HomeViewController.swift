//
//  HomeViewController.swift
//  Milestone2
//
//  Created by Default User on 3/14/24.
//
    
import UIKit
import EventKit
import Firebase

@IBDesignable
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    @IBOutlet weak var calendarViewBox: UIView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBInspectable var decorationColor: UIColor!
    @IBInspectable var tintColor: UIColor!
    
    var db: Firestore!
    var calendarView: UICalendarView!
    
    var taskList = [Task]()
    var dateList: [Date]!
    var selectedDay: DateComponents?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db = Firestore.firestore()
        
        refreshDates()
        
        configureCalendarView()
        
        if selectedDay != nil {
            refreshTasks(dateComp: selectedDay!)
        }

        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        taskTable.reloadData()
    }
    
    func configureCalendarView(){
        if calendarViewBox.viewWithTag(99) != nil {
            return
        }
        calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        let startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())
        let endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())
        let calendarViewDateRange = DateInterval(start: startDate!, end: endDate!)
        calendarView.visibleDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        calendarView.availableDateRange = calendarViewDateRange
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.tintColor = tintColor
        calendarView.tag = 99
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        calendarView.delegate = self
        calendarViewBox.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarViewBox.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewBox.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: calendarViewBox.centerXAnchor)
        ])
    }
    
    func refreshDates(){
        self.dateList = [Date]()
        db.collection("tasks").whereField("isComplete", isEqualTo: false).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let taskDate = ((document.data()["dueDate"]) as! Timestamp).dateValue().startOfDay;
                    if !self.dateList.contains(taskDate) { self.dateList.append(taskDate) }
                }
                self.calendarView.reloadDecorations(forDateComponents: self.dateToComponents(dates: self.getDateRange()), animated: true)
            }
        }
    }
    
    func refreshTasks(dateComp: DateComponents){
        var count = 0;
        db.collection("tasks")
            .whereField("dueDate", isDateEqual: dateComp)
            .order(by: "isComplete", descending: false)
            .getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                var taskList = [Task]()
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    if !task.isComplete {
                        count += 1
                    }
                    taskList.append(task)
                }
                self.taskList = taskList
                self.taskTable.reloadData();
                if count == 1 {
                    self.subtitleLabel.text = "You have 1 task for the day"
                } else {
                    self.subtitleLabel.text = "You have \(count) tasks for the day"
                }
            }
        }
    }
    
    func dateToComponents(dates: [Date]) -> [DateComponents]{
        var components = [DateComponents]()
        for d in dates {
            let comp = Calendar.current.dateComponents([.year, .month, .day], from: d)
            components.append(comp)
        }
        
        return components
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
        let taskView = DesignableTaskView.instanceFromNib(setTask: taskList[indexPath.row])
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.tag = 100
        cell.contentView.addSubview(taskView)
        return cell
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        if dateList.contains(dateComponents.date!.startOfDay) {
            return UICalendarView.Decoration.default(color: decorationColor, size: .small)
        }
            
        return nil
    }
    
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
        self.selectedDay = dateComponents
        refreshTasks(dateComp: dateComponents!)
    }
    
    func getDateRange() -> [Date] {
        var dates = [Date]()
        let current = Date()
        var start = current.getLastMonthStart()
        let end = current.getNextMonthEnd()
        while start! <= end! {
            dates.append(start!)
            start = Calendar.current.date(byAdding: .day, value: 1, to: start!)
        }
        
        return dates
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
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    //Last Month Start
    func getLastMonthStart() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month -= 1
        return Calendar.current.date(from: components as DateComponents)!
    }
    
    //Last Month End
    func getNextMonthEnd() -> Date? {
        let components:NSDateComponents = Calendar.current.dateComponents([.year, .month], from: self) as NSDateComponents
        components.month += 2
        return Calendar.current.date(from: components as DateComponents)!
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
