//
//  CourseListViewModel.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-22.
//

import Foundation

class CourseListViewModel {
    
    //MARK: - Variables
    
    private let firebaseManager = FirebaseManager.shared
    
    var errorMessage: String?
    
    var courseCollection = [DailyCourses]() // holds format for table view structure
    
    var onCoursesUpdated: (() -> Void)?
    var onCourseDeleted: (() -> Void)?
    var onError: ((String) -> Void)?
    
    
    //MARK: - Methods
    func fetchCourses() {
        firebaseManager.fetchCourses() { [weak self] result in
            switch result {
            case .success(let fetchedCourses):
                self?.courseCollection = [DailyCourses]()
                // Arrange courses in proper sections
                for course in fetchedCourses {
                    for schedule in course.schedule {
                        if self?.courseCollection.count == 0 {
                            self?.courseCollection.append(DailyCourses(weekday: schedule.day!, courses: [course]))
                        } else {
                            var added = false
                            for i in 0..<(self?.courseCollection.count)! {
                                if self?.courseCollection[i].weekday == schedule.day {
                                    self?.courseCollection[i].courses.append(course)
                                    added = true
                                    break
                                }
                            }
                            if added == false {
                                self?.courseCollection.append(DailyCourses(weekday: schedule.day!, courses: [course]))
                            }
                        }
                    }
                }
                
                if let courses = self?.courseCollection {
                    self?.courseCollection = self?.sortDailyCourses(courses) ?? []
                }
                
                self?.onCoursesUpdated?()  // Notify the view controller to update the UI
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred")  // Notify the view controller to show an error message
            }
        }
    }
    
    func deleteCourse(courseID: String) {
        FirebaseManager.shared.deleteCourse(courseId: courseID) { [weak self] result in
            switch result {
            case .success:
                self?.onCourseDeleted?()
            case .failure(let error):
                self?.errorMessage = error.localizedDescription
                self?.onError?(self?.errorMessage ?? "An error occurred") // Notify the view
            }
        }
    }
    
    //MARK: - Sorting Methods
    // Sort courses based on the startTime of the matching DaySchedule for the given weekday
    func sortCoursesByMatchingSchedule(for courses: [Course], weekday: DayOfWeek) -> [Course] {
        return courses.sorted { course1, course2 in
            // Extract the start time for the matching schedule or use a default time if not found
            let time1 = course1.schedule.first(where: { $0.day == weekday })?.startTime ?? Time(hour: 0, minute: 0)
            let time2 = course2.schedule.first(where: { $0.day == weekday })?.startTime ?? Time(hour: 0, minute: 0)
            return time1 < time2 // Sort by startTime
        }
    }

    // Sort DailyCourses by weekday and the courses within each day by the matching schedule’s startTime
    func sortDailyCourses(_ dailyCoursesList: [DailyCourses]) -> [DailyCourses] {
        // Define the order of weekdays
        let weekdayOrder: [DayOfWeek] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        
        // Sort DailyCourses by weekday using the defined weekday order
        let sortedDailyCourses = dailyCoursesList.sorted {
            guard let index1 = weekdayOrder.firstIndex(of: $0.weekday),
                  let index2 = weekdayOrder.firstIndex(of: $1.weekday) else {
                return false
            }
            return index1 < index2 // Compare based on the indices in weekdayOrder
        }

        // For each DailyCourses object, sort its courses based on the relevant startTime
        return sortedDailyCourses.map { dailyCourse in
            // Sort the courses for the current dailyCourse by their matching schedule
            let sortedCourses = sortCoursesByMatchingSchedule(for: dailyCourse.courses, weekday: dailyCourse.weekday)
            // Return a new DailyCourses instance with the sorted courses
            return DailyCourses(weekday: dailyCourse.weekday, courses: sortedCourses)
        }
    }
}
