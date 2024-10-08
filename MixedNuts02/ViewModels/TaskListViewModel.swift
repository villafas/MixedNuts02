//
//  HomeViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation

class TaskListViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared

    var dateList: [Date]!
    var errorMessage: String?
    
    var tempID: String?
    
    var taskCollection = [DailyTasks]() // holds format for table view structure
    
    var onTasksUpdated: (() -> Void)?
    var onDatesUpdated: (() -> Void)? // REMOVE
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    func fetchTasks() {
        firebaseManager.fetchTasks() { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                self?.taskCollection = [DailyTasks]()
                // Arrange tasks in proper sections
                for task in fetchedTasks {
                    if self?.taskCollection.count == 0 {
                        self?.taskCollection.append(DailyTasks(day: task.dueDate, tasks: [task]))
                    } else {
                        var added = false
                        for i in 0..<(self?.taskCollection.count)! {
                            if self?.taskCollection[i].day.startOfDay == task.dueDate.startOfDay {
                                self?.taskCollection[i].tasks.append(task)
                                added = true
                                break
                            }
                        }
                        if added == false {
                            self?.taskCollection.append(DailyTasks(day: task.dueDate, tasks: [task]))
                        }
                    }
                }
                
                self?.onTasksUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    // OLD
    func fetchTasks(forDate dateComp: DateComponents) {
        firebaseManager.fetchTasks(forDate: dateComp) { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                //self?.taskList = fetchedTasks
                self?.onTasksUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func fetchDates() {
        firebaseManager.fetchTaskDates() { [weak self] result in
            switch result {
            case .success(let fetchedDates):
                self?.dateList = fetchedDates
                self?.onDatesUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
}
