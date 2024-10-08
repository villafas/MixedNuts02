//
//  HomeViewController.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-07.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var courseBox: DesignableCourseBox!
    
    @IBOutlet weak var navBarBottom: UIView!
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var completedCount: UILabel!
    @IBOutlet weak var toDoCount: UILabel!
    @IBOutlet weak var taskTable: SelfSizedTableView!
    
    @IBOutlet weak var noTaskMessage: UIView!
    private let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navBarBottom.dropShadow()
        setUserName()
        courseBox.upcomingCourseNotSet()
        
        // Bind ViewModel to ViewController
        bindViewModel()
        
        taskTable.register(UITableViewCell.self, forCellReuseIdentifier: "task")
        taskTable.delegate = self
        taskTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshCounts()
        refreshCourse()
        refreshTasks()
    }
    
    //MARK: - Custom UI Functions
    
    func setUserName(){
        // Show user's name in welcome message
        self.nameTitle.text = "Hi, \(AppUser.shared.displayName ?? "User")"
    }
    
    func updateCounts() {
        completedCount.text = ("\(viewModel.weeklyTaskCount[0])")
        toDoCount.text = ("\(viewModel.weeklyTaskCount[1])")
    }
    
    func updateCourse() {
        if viewModel.nextCourse != nil {
            courseBox.courseTitle.text = viewModel.nextCourse!.title
            courseBox.courseSubtitle.text = ("\(viewModel.nextCourseSchedule!.classroom!) • \(getScheduleStatus(for: viewModel.nextCourseSchedule!))")
            courseBox.upcomingCourseSet()
        } else {
            courseBox.courseTitle.text = "No Classes Left"
            courseBox.courseSubtitle.text = ("You're free for the day!")
            courseBox.upcomingCourseNotSet()
        }
    }
    
    func updateTaskMessage(){
        if viewModel.taskCollection.count == 0 {
            noTaskMessage.isHidden = false
        } else {
            noTaskMessage.isHidden = true
        }
    }
    
    
    //MARK: - Model & Controller Binding
    
    private func bindViewModel() {
        // Handle UI Updates on changes to data
        viewModel.onTasksUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.taskTable.reloadData();
                self?.updateTaskMessage();
            }
        }
        
        viewModel.onCountsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCounts();
            }
        }
        
        viewModel.onCourseUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateCourse();
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
    
    //MARK: - Data Reading
    
    func refreshTasks(){
        viewModel.fetchTasks()
    }
    
    func refreshCourse(){
        viewModel.fetchNextCourse()
    }
    
    func refreshCounts(){
        viewModel.fetchWeeklyCourseCount()
    }
    
    //MARK: - Schedule Calculation
    
    func getScheduleStatus(for schedule: DaySchedule) -> String {
        guard let startTime = schedule.startTime?.toTodaysDate(),
              let endTime = schedule.endTime?.toTodaysDate() else {
            return "Invalid schedule times"
        }

        let now = Date()

        if now >= startTime && now <= endTime {
            return "Now"
        } else if now < startTime {
            let timeInterval = startTime.timeIntervalSince(now)
            let hours = Int(timeInterval / 3600)
            let minutes = Int(timeInterval.truncatingRemainder(dividingBy: 3600) / 60)

            if hours > 0 {
                return "Starts in \(hours) hours"
            } else if minutes > 0 {
                return "Starts in \(minutes) minutes"
            }
        }

        return "Starts later today"
    }
    
    
    //MARK: - Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.taskCollection.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        let numberOfSections = tableView.numberOfSections
        
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
        
        let task = viewModel.taskCollection[indexPath.row]
        
        // otherwise, show regular task view
        let taskView = DesignableTaskView.instanceFromNib(setTask: task)
        taskView.translatesAutoresizingMaskIntoConstraints = false
        taskView.heightAnchor.constraint(equalToConstant: 81).isActive = true
        taskView.widthAnchor.constraint(equalToConstant: taskTable.frame.width).isActive = true
        taskView.tag = 100
        //taskView.deleteButton.addTarget(self, action: #selector(showDeleteAction(_:)), for: .touchUpInside)
        //taskView.taskButton.addTarget(self, action: #selector(showDoneAction(_:)), for: .touchUpInside)
        cell.contentView.addSubview(taskView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Row selection
    }
}
