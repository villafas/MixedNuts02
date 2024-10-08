//
//  DBContext.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-03.
//

import Foundation
import Firebase

class FirebaseManager {
    
    //MARK: - Properties
    
    static let shared = FirebaseManager() // make available globally
    
    private let db = Firestore.firestore()
    
    //MARK: - Custom types
    
    // Define a tuple type for the result
    typealias CourseWithSchedule = (course: Course, daySchedule: DaySchedule?)
    
    
    //MARK: - Constructors
    
    private init() {
        // Private init to prevent others from creating instances
        //FirebaseApp.configure()
    }
    
    
    //MARK: - Fetch Methods
    func fetchTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        tasksCollection
            .whereField("isComplete", isEqualTo: false)
            .order(by: "dueDate")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var tasks: [Task] = []
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    tasks.append(task)
                }
                
                completion(.success(tasks))
            }
    }
    
    func fetchTodaysTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start of today (00:00:00)
        let startOfDay = calendar.startOfDay(for: now)
        
        // Get the end of today (23:59:59)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        
        tasksCollection
            .whereField("dueDate", isGreaterThanOrEqualTo: startOfDay)
            .whereField("dueDate", isLessThanOrEqualTo: endOfDay)
            .order(by: "isComplete")
            .order(by: "dueDate")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var tasks: [Task] = []
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    tasks.append(task)
                }
                
                completion(.success(tasks))
            }
    }
    
    func fetchCourses(completion: @escaping (Result<[Course], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let courseCollection = userDbRef.collection("courses")
        
        courseCollection
            .order(by: "title")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var courses: [Course] = []
                for document in querySnapshot!.documents {
                    let course = Course(snapshot: document)
                    courses.append(course)
                }
                
                completion(.success(courses))
            }
    }
    
    func fetchNextCourse(completion: @escaping (Result<CourseWithSchedule?, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let courseCollection = userDbRef.collection("courses")
        
        let now = Date()
        let currentDay = getCurrentDayString() // E.g., "Monday"
        
        // Query Firestore for courses scheduled for today
        courseCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var currentCourse: CourseWithSchedule?
            var nextCourse: CourseWithSchedule?
            var nextCourseStartTime: Date?
            
            for document in querySnapshot!.documents {
                let data = document.data()
                
                // Access the course schedule (array of DaySchedule)
                if let scheduleArray = data["schedule"] as? [[String: Any]] {
                    for dayScheduleDict in scheduleArray {
                        if let daySchedule = DaySchedule(dictionary: dayScheduleDict),
                           daySchedule.day?.rawValue.lowercased() == currentDay.lowercased() {
                            // Check the start and end times for today
                            if let startTime = daySchedule.startTime?.toTodaysDate(),
                               let endTime = daySchedule.endTime?.toTodaysDate() {
                                if now >= startTime && now <= endTime {
                                    // This course is currently happening
                                    currentCourse = (Course(snapshot: document), daySchedule)
                                    break
                                } else if now < startTime {
                                    // This course is upcoming, check if it's the next one
                                    if nextCourseStartTime == nil || startTime < nextCourseStartTime! {
                                        nextCourse = (Course(snapshot: document), daySchedule)
                                        nextCourseStartTime = startTime
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Return the current or next course with its corresponding schedule
            if let currentCourse = currentCourse {
                completion(.success(currentCourse))
            } else if let nextCourse = nextCourse {
                completion(.success(nextCourse))
            } else {
                completion(.success(nil))
            }
        }
    }
    
    func fetchWeeklyCourseCount(completion: @escaping (Result<[Int], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        let calendar = Calendar.current
        let now = Date()
        
        // Get the start of the week (e.g., Monday at 00:00:00)
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        
        // Get the end of the week (e.g., Sunday at 23:59:59)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let endOfWeekEndOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfWeek)!
        
        
        // Query for tasks due this week (from startOfWeek to endOfWeekEndOfDay)
        tasksCollection
            .whereField("dueDate", isGreaterThanOrEqualTo: startOfWeek)
            .whereField("dueDate", isLessThanOrEqualTo: endOfWeekEndOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var taskCount: [Int] = []
                var completeCount: Int = 0
                var incompleteCount: Int = 1
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    if task.isComplete == true {
                        completeCount += 1
                    } else {
                        incompleteCount += 1
                    }
                }
                
                taskCount.append(completeCount)
                taskCount.append(incompleteCount)
                
                completion(.success(taskCount))
            }
    }
    
    func fetchTerms(completion: @escaping (Result<[Term], Error>) -> Void) {
        let termCollection = db.collection("terms")
        
        termCollection
            .order(by: "startDate")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var terms: [Term] = []
                for document in querySnapshot!.documents {
                    let term = Term(snapshot: document)
                    terms.append(term)
                }
                
                completion(.success(terms))
            }
    }
    
    //MARK: - Add Methods
    
    // Function to add a task to Firestore using toAnyObject()
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        let taskData = task.toAnyObject()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        tasksCollection.addDocument(data: taskData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    // Function to add a task to Firestore using toAnyObject()
    func addCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
        let courseData = course.toAnyObject()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let coursesCollection = userDbRef.collection("courses")
        
        coursesCollection.addDocument(data: courseData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
        
        
        //func addTask{
        /*if let title = titleField.text, let course = courseField.text, !title.isEmpty, !course.isEmpty {
         let dueDate = combineDateWithTime(date: datePicker.date, time: timePicker.date)!
         var task = Task(id: "", title: title, course: course, notes: notesView.text, dueDate: dueDate, markWeight: 0, isComplete: false)
         let userDbRef = self.db.collection("users").document(AppUser.shared.uid!)
         var ref: DocumentReference? = nil
         ref = userDbRef.collection("tasks").addDocument(data: task.toAnyObject()) { err in
         if let err = err {
         print("Error adding document: \(err)")
         } else {
         print("Document added with ID: \(ref!.documentID)")
         task.id = ref!.documentID
         self.scheduleNotifications(taskObj: task)
         }
         }
         titleField.text = ""
         courseField.text = ""
         notesView.text = ""
         self.datePicker.date = Date()
         self.timePicker.date = Date()
         }*/
    }
    
    
    // OLD
    func fetchTasks(forDate dateComp: DateComponents, completion: @escaping (Result<[Task], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        tasksCollection
            .whereField("dueDate", isDateEqual: dateComp)
            .order(by: "isComplete", descending: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var tasks: [Task] = []
                for document in querySnapshot!.documents {
                    let task = Task(snapshot: document)
                    tasks.append(task)
                }
                
                completion(.success(tasks))
            }
    }
    
    func fetchTaskDates(completion: @escaping (Result<[Date], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        tasksCollection
            .whereField("isComplete", isEqualTo: false)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var dates: [Date] = []
                for document in querySnapshot!.documents {
                    let taskDate = ((document.data()["dueDate"]) as! Timestamp).dateValue().startOfDay;
                    dates.append(taskDate)
                }
                
                completion(.success(dates))
            }
    }
    
    
    //MARK: - Helper functions
    
    // Helper function to get the current day of the week as a string (e.g., "Monday")
    func getCurrentDayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE" // Day format as full name, like "Monday"
        return dateFormatter.string(from: Date())
    }
}
