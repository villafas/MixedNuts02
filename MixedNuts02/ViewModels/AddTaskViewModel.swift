//
//  AddTaskViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-30.
//

import Foundation

class AddTaskViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var courseList: [Course]!
    var errorMessage: String?
    
    var newID: String?
    var notifIntervals: [TimeInterval]?
    
    var onTaskAdded: (() -> Void)?
    var onTaskUpdated: (() -> Void)?
    var onCoursesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    //MARK: - Methods
    func addTask(title: String, course: String, notes: String?, dueDate: Date, markWeight: Int?) {
        var newTask = Task(id: "", title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight, isComplete: false)
        
        FirebaseManager.shared.addTask(newTask) { [weak self] result in
            switch result {
            case .success(let taskID):
                self?.newID = taskID
                newTask.id = taskID
                NotificationHelper.scheduleNotifications(taskObj: newTask, intervals: self?.notifIntervals ?? [])
                self?.onTaskAdded?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func fetchCourses() {
        firebaseManager.fetchCourses() { [weak self] result in
            switch result {
            case .success(let fetchedCourses):
                self?.courseList = fetchedCourses
                self?.onCoursesUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func updateTask(task: Task) {
        FirebaseManager.shared.updateTask(task) { [weak self] result in
            switch result {
            case .success:
                NotificationHelper.deleteNotifications(taskId: task.id, deletePending: true)
                NotificationHelper.scheduleNotifications(taskObj: task, intervals: self?.notifIntervals ?? [])
                self?.onTaskUpdated?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred") // Notify the view
            }
        }
    }
}

