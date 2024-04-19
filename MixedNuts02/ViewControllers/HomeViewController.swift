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
        self.hideKeyboardWhenTappedAround() 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        db = Firestore.firestore()
        
        setUserName()
        
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
    
    func setUserName(){
        self.mainTitle.text = "Welcome Back, \(AppUser.shared.displayName ?? "User")!"
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
        
        let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
        
        userDbRef.collection("tasks").whereField("isComplete", isEqualTo: false).getDocuments() { (querySnapshot, err) in
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

        let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
        
        userDbRef.collection("tasks")
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
        taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
        taskView.tag = 100
        cell.contentView.addSubview(taskView)
        cell.backgroundColor = UIColor.white
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

// Put this piece of code anywhere you like
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scheduleNotification(taskObj: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to complete \(taskObj.title)!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "\(taskObj.id)"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "Temp", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    func sampleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "YOU'RE 2 WEEKS LATE!?"
        content.body = "Hurry up and submit PPP 5!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "OWzmE20GfPngZo429Y0i"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: "Temp", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    func scheduleNotifications(taskObj: Task){
        // Define time intervals
        let intervals: [TimeInterval] = [-3*24*60*60,
        -1*24*60*60, -12*60*60, -1*60*60, -1*60, 1*60]
        // 3 days before, 1 day before, 12 hours before, 1 hour before, 1 minute before, 1 minute after
        
        for interval in intervals {
            var content: UNMutableNotificationContent?
            var triggerDate: Date?
            var trigger: UNCalendarNotificationTrigger?
            var request: UNNotificationRequest?
            if interval == -3*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "3 Days Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_3D", content: content!, trigger: trigger)
            } else if interval == -1*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Day Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1D", content: content!, trigger: trigger)
            } else if interval == -12*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "12 Hours Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_12H", content: content!, trigger: trigger)
            } else if interval == -1*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Hour Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1H", content: content!, trigger: trigger)
            } else if interval == -1*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Minute Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1M", content: content!, trigger: trigger)
            } else if interval == 1*60 {
                content = UNMutableNotificationContent()
                content!.title = "You missed it"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1L", content: content!, trigger: trigger)
            }

            UNUserNotificationCenter.current().add(request!) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    //print("Notification scheduled successfully")
                }
            }
        }
    }
    
    func deleteNotifications(taskId: String, deletePending: Bool){
        let idExtensions: [String] = ["\(taskId)_3D", "\(taskId)_1D", "\(taskId)_12H", "\(taskId)_1H", "\(taskId)_1M", "\(taskId)_1L"]

        if deletePending {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idExtensions)
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idExtensions)
    }
}
