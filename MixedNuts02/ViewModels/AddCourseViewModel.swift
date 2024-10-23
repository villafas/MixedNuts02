//
//  AddCourseViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-30.
//

import Foundation

class AddCourseViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var termList: [Term]!
    var errorMessage: String?
    
    var newID: String?
    
    var onCourseAdded: (() -> Void)?
    var onCourseUpdated: (() -> Void)?
    var onTermsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    func addCourse(title: String, code: String, schedule: [DaySchedule], term: String, prof: String?, courseURL: String?) {
        var newCourse = Course(id: "", title: title, code: code, schedule: schedule, term: term, prof: prof, courseURL: courseURL)
        
        FirebaseManager.shared.addCourse(newCourse) { [weak self] result in
            switch result {
            case .success(let courseID):
                self?.newID = courseID
                newCourse.id = courseID
                self?.onCourseAdded?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view
            }
        }
    }
    
    func fetchTerms() {
        firebaseManager.fetchTerms() { [weak self] result in
            switch result {
            case .success(let fetchedTerms):
                self?.termList = fetchedTerms
                self?.onTermsUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func updateCourse(course: Course) {
        FirebaseManager.shared.updateCourse(course) { [weak self] result in
            switch result {
            case .success:
                self?.onCourseUpdated?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred") // Notify the view
            }
        }
    }
}
