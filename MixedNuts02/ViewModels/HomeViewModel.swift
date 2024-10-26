//
//  HomeViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-07.
//

import Foundation

class HomeViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared

    var errorMessage: String?
    
    var taskCollection = [Task]() // holds format for table view structure
    var weeklyTaskCount = [Int]()
    var nextCourse: Course?
    var nextCourseSchedule: DaySchedule?
    
    var onUserLogged: (() -> Void)?
    var onTasksUpdated: (() -> Void)?
    var onCountsUpdated: (() -> Void)?
    var onCourseUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    func fetchTasks() {
        firebaseManager.fetchTodaysTasks() { [weak self] result in
            switch result {
            case .success(let fetchedTasks):
                self?.taskCollection = fetchedTasks
                self?.onTasksUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func fetchWeeklyCourseCount() {
        firebaseManager.fetchWeeklyCourseCount() { [weak self] result in
            switch result {
            case .success(let fetchedCounts):
                self?.weeklyTaskCount = fetchedCounts
                self?.onCountsUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func fetchNextCourse() {
        firebaseManager.fetchNextCourse() { [weak self] result in
            switch result {
            case .success(let fetchedCourse):
                if fetchedCourse != nil {
                    self?.nextCourse = fetchedCourse?.course
                    self?.nextCourseSchedule = fetchedCourse?.daySchedule
                    self?.onCourseUpdated?()  // Notify the view controller to update the UI
                }
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func fetchUserDetails() {
        firebaseManager.fetchUserDetails(AppUser.shared.uid ?? "") { [weak self] result in
            switch result {
            case .success(let fetchedDetails):
                AppUser.shared.firstName = fetchedDetails[0]
                AppUser.shared.lastName = fetchedDetails[1]
                self?.onUserLogged?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    
}
