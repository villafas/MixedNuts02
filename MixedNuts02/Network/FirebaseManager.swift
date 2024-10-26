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
                var incompleteCount: Int = 0
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
    
    func fetchUserDetails(_ userId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "User not found", code: 404, userInfo: nil)))
                return
            }
            
            var details: [String] = []
            
            // Extracting the fields
            details.append(document.get("firstName") as? String ?? "No first name")
            details.append(document.get("lastName") as? String ?? "No last name")
            
            // Returning the results as a tuple
            completion(.success(details))
        }
    }
    
    func isUsernameTaken(_ username: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        
        usersCollection
            .whereField("username", isEqualTo: username)
            .limit(to: 1)  // We only care if one match exists
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let isTaken = !querySnapshot!.documents.isEmpty  // Check if a matching document exists
                completion(.success(isTaken))
            }
    }
    
    //MARK: - CRUD Methods
    
    // Function to add a task to Firestore using toAnyObject()
    func addTask(_ task: Task, completion: @escaping (Result<String, Error>) -> Void) {
        let taskData = task.toAnyObject()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        // Add a new document with an auto-generated ID and get the reference
        let newDocumentRef = tasksCollection.addDocument(data: taskData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        // Use the document reference to get the ID directly
        let taskID = newDocumentRef.documentID  // Get the auto-generated ID
        completion(.success(taskID))  // Return the ID
    }
    
    // Function to add a task to Firestore using toAnyObject()
    func addCourse(_ course: Course, completion: @escaping (Result<String, Error>) -> Void) {
        let courseData = course.toAnyObject()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let coursesCollection = userDbRef.collection("courses")
        
        // Add a new document with an auto-generated ID and get the reference
        let newDocumentRef = coursesCollection.addDocument(data: courseData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        // Use the document reference to get the ID directly
        let courseID = newDocumentRef.documentID  // Get the auto-generated ID
        completion(.success(courseID))  // Return the ID
    }
    
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        let taskData = task.toAnyObject()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        let taskRef = tasksCollection.document(task.id)
        
        taskRef.updateData(taskData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateTaskCompletion(taskID: String, isComplete: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        let taskRef = tasksCollection.document(taskID)
        
        // Update only the isComplete field
        taskRef.updateData(["isComplete": isComplete]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func updateCourse(_ course: Course, completion: @escaping (Result<Void, Error>) -> Void) {
        let courseData = course.toAnyObject()  // Convert Course object to a dictionary
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let coursesCollection = userDbRef.collection("courses")
        let courseRef = coursesCollection.document(course.id)
        
        courseRef.updateData(courseData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func deleteTask(taskId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        let taskRef = tasksCollection.document(taskId)
        
        taskRef.delete { error in
            if let error = error {
                completion(.failure(error)) // If there's an error, call the failure case
            } else {
                completion(.success(())) // Success case
            }
        }
    }
    
    func deleteCourse(courseId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let coursesCollection = userDbRef.collection("courses")
        let courseRef = coursesCollection.document(courseId)
        
        courseRef.delete { error in
            if let error = error {
                completion(.failure(error)) // If there's an error, call the failure case
            } else {
                completion(.success(())) // Success case
            }
        }
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
