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
    
    var onTaskAdded: (() -> Void)?
    var onTaskUpdated: (() -> Void)?
    var onCoursesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    //MARK: - Methods
    func addTask(title: String, course: String, notes: String?, dueDate: Date, markWeight: Int?) {
        let newTask = Task(id: "", title: title, course: course, notes: notes, dueDate: dueDate, markWeight: markWeight, isComplete: false)
        
        FirebaseManager.shared.addTask(newTask) { [weak self] result in
            switch result {
            case .success:
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
                self?.onTaskUpdated?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred") // Notify the view
            }
        }
    }
}

