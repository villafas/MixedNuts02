//
//  HomeViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation

class HomeViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var taskList = [Task]()
    var dateList: [Date]!
    var selectedDay: DateComponents?
    var errorMessage: String?
    
    var onTasksUpdated: (() -> Void)?
    var onDatesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    
    func fetchTasks(forDate dateComp: DateComponents) {
        firebaseManager.fetchTasks(forDate: dateComp) { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                self?.taskList = fetchedTasks
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
