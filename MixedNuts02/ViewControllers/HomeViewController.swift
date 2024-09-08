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
    
    //MARK: - Properties
    
    @IBOutlet weak var calendarViewBox: UIView!
    @IBOutlet weak var taskTable: UITableView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var mainTitle: UILabel!
    
    @IBInspectable var decorationColor: UIColor!
    @IBInspectable var tintColor: UIColor!
    
    var calendarView: UICalendarView!
    
    private let viewModel = HomeViewModel()
    
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable hiding keyboard on tap
        self.hideKeyboardWhenTappedAround()
        
        // Bind ViewModel to ViewController
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUserName()
        
        // Set proper Date Decorations
        refreshDates()
        
        // Set today's date if none is selected
        if viewModel.selectedDay == nil {
            let today = Date()
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: today)
            let dateComponents = calendar.dateComponents([.year, .month, .day], from: startOfDay)
            viewModel.selectedDay = dateComponents
        }
        
        // Configure CalendarView
        configureCalendarView()
        
        // Get Tasks
        refreshTasks(dateComp: viewModel.selectedDay!)
        
        // Configure the TableView
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        taskTable.reloadData()
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
        dateSelection.selectedDate = viewModel.selectedDay
        calendarView.delegate = self
        calendarViewBox.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calendarViewBox.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: calendarViewBox.trailingAnchor),
            calendarView.centerXAnchor.constraint(equalTo: calendarViewBox.centerXAnchor)
        ])
    }
    
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTasksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.taskTable.reloadData();
                
                // Set subtitle
                var count = 0
                for task in self!.viewModel.taskList {
                    if !task.isComplete {
                        count += 1
                    }
                }
                
                if count == 1 { // task singular for 1 day
                    self?.subtitleLabel.text = "You have 1 task for the day"
                } else { // else, tasks plural
                    self?.subtitleLabel.text = "You have \(count) tasks for the day"
                }
            }
        }
        
        viewModel.onDatesUpdated = { [weak self] in
            DispatchQueue.main.async {
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
    
    
    //MARK: - Custom UI Functions
    
    func setUserName(){
        // Show user's name in welcome message
        self.mainTitle.text = "Welcome Back, \(AppUser.shared.displayName ?? "User")!"
    }
    
    
    //MARK: - Data Reading
    
    func refreshDates(){
        // refresh dates containing tasks to show necessary decorations
        viewModel.dateList = [Date]()
        viewModel.fetchDates()
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
    
    
    //MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // row count
        return viewModel.taskList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // row height
        return 96.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // table cell creation
        let cell = tableView.dequeueReusableCell(withIdentifier: "task", for: indexPath)
        // if cell exists, delete prior to adding
        if let viewWithTag = cell.contentView.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
        // Create cell using task view
        let taskView = DesignableTaskView.instanceFromNib(setTask: viewModel.taskList[indexPath.row])
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
        taskView.tag = 100
        cell.contentView.addSubview(taskView)
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    
    //MARK: - CalendarView Delegate
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        // calendar decorations
        if viewModel.dateList.contains(dateComponents.date!.startOfDay) {
            return UICalendarView.Decoration.default(color: decorationColor, size: .small)
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        // calendar date is selected
        viewModel.selectedDay = dateComponents
        refreshTasks(dateComp: dateComponents!)
    }
}


