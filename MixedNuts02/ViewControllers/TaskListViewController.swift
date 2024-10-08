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
class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    //MARK: - Properties
    
    @IBOutlet weak var calendarViewBox: UIView!
    @IBOutlet weak var navBarHeader: UIView!
    @IBOutlet weak var navBarContent: UIView!
    @IBOutlet weak var taskTable: SelfSizedTableView!
    var selectedRow: IndexPath?
    @IBOutlet weak var navBarBottom: UIView!
    
    var navBarIsExpanded: Bool = false // tracks detail panel toggle state
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var popupDeleteView: UIView!
    @IBOutlet var popupDoneView: UIView!
    
    @IBInspectable var decorationColor: UIColor!
    @IBInspectable var tintColor: UIColor!
    
    var calendarView: UICalendarView!
    var selectedDay: DateComponents?
    
    private let viewModel = TaskListViewModel()
    var notifID: String?
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounds for popups
        popupDeleteView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        popupDoneView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        // Enable hiding keyboard on tap
        self.hideKeyboardWhenTappedAround()
        
        // Bind ViewModel to ViewController
        bindViewModel()
        
        // Set drop shadow for navBar
        navBarBottom.dropShadow()
        
        // Set today's date if none is selected
        if self.selectedDay == nil {
            let today = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: today)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: startOfDay)
            self.selectedDay = dateComponents
        }
        
        // Configure CalendarView
        configureCalendarView()
        
        //
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        //taskTable.contentInset = UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set proper Date Decorations
        //refreshDates()
        
        // Get Tasks
        refreshTasks()
    }
    
    
    //MARK: - CalendarView Configuration
    
    func configureCalendarView(){
        // if calendar view exists, do not configure
        if calendarViewBox.viewWithTag(99) != nil {
            return
        }
        
        // configure calendar view logic
        calendarView = UICalendarView()
        calendarView.calendar = Calendar(identifier: .gregorian)
        // date range
        let startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())
        let endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())
        let calendarViewDateRange = DateInterval(start: startDate!, end: endDate!)
        calendarView.visibleDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        calendarView.availableDateRange = calendarViewDateRange
        // style & id
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        calendarView.tintColor = tintColor
        calendarView.tag = 99
        // date selection
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = dateSelection
        dateSelection.selectedDate = self.selectedDay
        calendarView.delegate = self
        calendarViewBox.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarViewBox.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewBox.trailingAnchor),
            calendarView.topAnchor.constraint(equalTo: calendarViewBox.topAnchor)
        ])
    }
    
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTasksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.taskTable.reloadData();
                self?.calendarView.reloadDecorations(forDateComponents: self!.dateToComponents(dates: self!.getDateRange()), animated: true)
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                // Show error message (e.g., using an alert)
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    
    @IBAction func navBarIsTapped(_ sender: UITapGestureRecognizer) {
        // Toggle state
        navBarIsExpanded.toggle()
        
        hideOrShowPanel()
    }
    
    
    func hideOrShowPanel(){
        let calendarHeight = calendarView.frame.height
        
        // Scroll in and out of detail panel based on the toggle state
        navBarHeightConstraint.constant = navBarIsExpanded ? CGFloat(calendarHeight - 20) : CGFloat(0)
        
        UIView.animate(withDuration: 0.3){
            self.view.layoutIfNeeded()
            
            // Optional: Update the shadow path if necessary
            let shadowPath = UIBezierPath(rect: self.navBarBottom.bounds)
            self.navBarBottom.layer.shadowPath = shadowPath.cgPath
        }
    }
    
    //MARK: - Data Reading
    
    func refreshDates(){
        // refresh dates containing tasks to show necessary decorations
        viewModel.dateList = [Date]()
        viewModel.fetchDates()
    }
    
    func refreshTasks(){
        viewModel.fetchTasks()
    }
    
    func refreshTasks(dateComp: DateComponents){
        // logic for showing tasks when a date is selected
        viewModel.fetchTasks(forDate: dateComp)
    }
    
    
    //MARK: - Date Formatting
    
    func getDateRange() -> [Date] {
        // date range for limiting decoration refreshing and improve efficiency
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
    
    func dateToComponents(dates: [Date]) -> [DateComponents]{
        // conversion to assist with different date formats
        var components = [DateComponents]()
        for d in dates {
            let comp = Calendar.current.dateComponents([.year, .month, .day], from: d)
            components.append(comp)
        }
        
        return components
    }
    
    //MARK: - Notification task selection
    
    func selectNotificationTask(){
        // iterate through the tasks in each section to find the task corresponding to the notification
        for section in 0..<viewModel.taskCollection.count{
            var count = 0
            for task in viewModel.taskCollection[section].tasks {
                if task.id == self.notifID {
                    let index = IndexPath(row: count, section: section)
                    self.selectedRow = index
                    taskTable.selectRow(at: index, animated: true, scrollPosition: .middle)
                    self.notifID = nil
                    return
                }
                count += 1
            }
        }
    }
    
    //MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.taskCollection.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // section title
        let cell = tableView.dequeueReusableCell(withIdentifier: "sectionTitle")! as! SectionTitleView
        let taskDate = viewModel.taskCollection[section].day.startOfDay
        var dateTitle = ""
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        dateTitle = formatter.string(from: taskDate)
        if taskDate == Calendar.current.date(byAdding: .day, value: -1, to: Date())?.startOfDay{
            dateTitle += " - Yesterday"
        } else if taskDate == Date().startOfDay{
            dateTitle += " - Today"
        } else if taskDate == Calendar.current.date(byAdding: .day, value: 1, to: Date())?.startOfDay{
            dateTitle += " - Tomorrow"
        }
        
        cell.title!.text = dateTitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.taskCollection[section]
        return section.tasks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let numberOfSections = tableView.numberOfSections
        
        // if task is selected, expand its size
        if indexPath == self.selectedRow{
            if indexPath.section != numberOfSections - 1 && indexPath.row == numberOfRows - 1 {
                // This is the last row in the section if it's selected
                return 400.0
            } else {
                // For other selected rows
                return 415.0
            }
        }
        
        if indexPath.section != numberOfSections - 1 && indexPath.row == numberOfRows - 1 {
            // This is the last row in the section if it's not selected
            return 81.0
        }
        
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cell configuration
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        cell.selectionStyle = .none
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        let section = viewModel.taskCollection[indexPath.section]
        let task = section.tasks[indexPath.row]
        
        // if selected, show expanded task
        if (indexPath == self.selectedRow){
            self.deleteNotifications(taskId: task.id, deletePending: false)
            let taskView = DesignableExpandedTaskView.instanceFromNib(setTask: task)
            taskView.translatesAutoresizingMaskIntoConstraints = false
            taskView.heightAnchor.constraint(equalToConstant: 400).isActive = true
            taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
            taskView.tag = 100
            taskView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
            //taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
            //taskView.saveButton.addTarget(self, action: #selector(saveAction(_:)), for: .touchUpInside)
            //taskView.updateButtons(urlText: taskView.urlField.text!)
            
            taskView.editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            
            cell.contentView.addSubview(taskView)
            return cell
        }
        
        // otherwise, show regular task view
        let taskView = DesignableTaskView.instanceFromNib(setTask: task)
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
        taskView.tag = 100
        //taskView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
        taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
        cell.contentView.addSubview(taskView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selection
        if indexPath == self.selectedRow {
            self.taskTable.deselectRow(at: indexPath, animated: true)
            self.selectedRow = nil
        } else {
            self.selectedRow = indexPath
        }
        self.taskTable.reloadData()
        self.taskTable.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // row deselection
        self.selectedRow = nil
    }
    
    func totalItems(_ sections: [DailyTasks]) -> Int {
        // get the total number of tasks in all sections
        return sections.reduce(0) { $0 + $1.tasks.count }
    }
    
    
    //MARK: - CalendarView Delegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // calendar decorations
        if viewModel.taskCollection.contains(where: { $0.day.startOfDay == dateComponents.date!.startOfDay }) {
            return UICalendarView.Decoration.default(color: decorationColor, size: .small)
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        // calendar date is selected
        self.selectedDay = dateComponents
        
        if let sectionIndex = viewModel.taskCollection.firstIndex(where: { Calendar.current.isDate($0.day, inSameDayAs: (dateComponents?.date)!) }) {
            let indexPath = IndexPath(row: 0, section: sectionIndex)
            
            navBarIsExpanded.toggle()
            hideOrShowPanel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.taskTable.scrollToRow(at: indexPath, at: .top, animated: true)
            }
            
        }
    }
    
    //MARK: - Task editing
    
    // Button action that triggers the segue
    @objc func editButtonTapped() {
        // Trigger the segue programmatically
        performSegue(withIdentifier: "showEditSegue", sender: self)
    }
    
    // Prepare data for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditSegue" {
            // Get the destination view controller
            if let destinationVC = segue.destination as? EditTaskViewController, let selectedTask = taskTable.cellForRow(at: selectedRow!)?.viewWithTag(100) as? DesignableExpandedTaskView {
                // Pass data to the destination view controller
                destinationVC.taskObj = selectedTask.taskObj
            }
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        // update fields
        /*
         if let taskView = sender.superview?.superview?.superview as! DesignableExpandedTaskView? {
         let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
         let docRef = userDbRef.collection("tasks").document(taskView.taskObj!.id)
         docRef.getDocument() { (querySnapshot, err) in
         if let err = err {
         print("Error getting document: \(err)")
         } else {
         querySnapshot!.reference.updateData([
         "taskURL" : taskView.urlField.text!
         ])
         querySnapshot!.reference.updateData([
         "notes" : taskView.notesView.text!
         ])
         self.refreshTasks()
         }
         }
         }
         */
    }
    
    
    //MARK: - Delete task
    @IBAction func showDeleteAction(_ sender: UIButton) {
        // show delete popup
        if let card = popupDeleteView.viewWithTag(95) as! DesignablePopUpCard?, let taskView = sender.superview?.superview as? DesignableEditTaskView? ?? sender.superview?.superview as? DesignableExpandedTaskView? {
            card.titleLabel.text = "\(taskView!.taskObj!.title)"
            viewModel.tempID = taskView!.taskObj!.id
        }
        animateScaleIn(desiredView: popupDeleteView, doneOrCancel: false)
    }
    
    @IBAction func doneDeleteAction(_ sender: UIButton) {
        // delete is confirmed, so delete document
        animateScaleOut(desiredView: popupDeleteView)
        /*
         if sender.tag == 91 {
         self.deleteNotifications(taskId: self.tempID!, deletePending: true)
         let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
         let docRef = userDbRef.collection("tasks").document(self.tempID!)
         docRef.getDocument() { (querySnapshot, err) in
         if let err = err {
         print("Error getting document: \(err)")
         } else {
         querySnapshot!.reference.delete()
         self.selectedRow = nil
         self.refreshTasks()
         }
         }
         } else {
         tempID = nil
         }
         */
    }
    
    //MARK: - Complete task
    @IBAction func showDoneAction(_ sender: UIButton) {
        // show congrats popup
        if let card = popupDoneView as! DesignableDoneCard?, let taskView = sender.superview?.superview as? DesignableEditTaskView? ?? sender.superview?.superview as? DesignableExpandedTaskView?{
            self.deleteNotifications(taskId: taskView!.taskObj!.id, deletePending: true)
            card.titleLabel.text = "\(taskView!.taskObj!.title)"
            card.subtitleLabel.text = "Remaining Tasks: \((totalItems(viewModel.taskCollection)) - 1)"
            /*
             let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
             let docRef = userDbRef.collection("tasks").document(taskView!.taskObj!.id)
             docRef.getDocument() { (querySnapshot, err) in
             if let err = err {
             print("Error getting document: \(err)")
             } else {
             querySnapshot!.reference.updateData([
             "isComplete" : true
             ])
             self.selectedRow = nil
             self.refreshTasks()
             }
             }
             */
            animateScaleIn(desiredView: popupDoneView, doneOrCancel: true)
        }
    }
    
    @IBAction func doneDoneAction(_ sender: UIButton) {
        // dismiss popup
        animateScaleOut(desiredView: popupDoneView)
    }
    
    //MARK: - Popup animations
    /// Animates a view to scale in and display
    func animateScaleIn(desiredView: UIView, doneOrCancel: Bool) {
        let backgroundView = self.view!
        backgroundView.addSubview(desiredView)
        desiredView.center = backgroundView.center
        desiredView.isHidden = false
        
        
        
        desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        desiredView.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            desiredView.alpha = 1
            //            desiredView.transform = CGAffineTransform.identity
        }
    }
    
    /// Animates a view to scale out remove from the display
    func animateScaleOut(desiredView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            desiredView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            desiredView.alpha = 0
        }, completion: { (success: Bool) in
            desiredView.removeFromSuperview()
        })
        
        UIView.animate(withDuration: 0.2, animations: {
            
        }, completion: { _ in
            
        })
    }
    
}



