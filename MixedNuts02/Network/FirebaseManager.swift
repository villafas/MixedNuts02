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
    
    // Fetching Today's Task
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

    
    
    // Fetching the Weeks Task
    func fetchWeeklyTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("tasks")
        
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        tasksCollection
            .whereField("dueDate", isGreaterThanOrEqualTo: startOfWeek)
            .whereField("dueDate", isLessThanOrEqualTo: endOfWeek)
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
    
    //Fetch the Pending Tasks
    func fetchPendingTasks(completion: @escaping (Result<[SharedTask], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("sharedTasks")
        
        tasksCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            var tasks: [SharedTask] = []
            let dispatchGroup = DispatchGroup()  // Create a dispatch group
            
            for document in querySnapshot!.documents {
                let uid = document.get("uid") as! String
                let task = Task(snapshot: document)
                
                dispatchGroup.enter()  // Enter the group before starting async work
                
                self.fetchFriendDetails(usingId: uid) { result in
                    switch result {
                    case .success(let friendDetails):
                        tasks.append(SharedTask(user: friendDetails, task: task))
                    case .failure(let error):
                        completion(.failure(error))
                        return  // Exit early if an error occurs
                    }
                    dispatchGroup.leave()  // Leave the group after the async task completes
                }
            }
            
            // Notify when all async tasks are done
            dispatchGroup.notify(queue: .main) {
                completion(.success(tasks))
            }
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
    
    
    //MARK: - End of task
    
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
    
    func fetchFriends(completion: @escaping (Result<[Friendship], Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let friendCollection = userDbRef.collection("friends")
        
        friendCollection
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var friends: [Friendship] = []
                for document in querySnapshot!.documents {
                    let friend = Friendship(snapshot: document)
                    friends.append(friend)
                }
                
                completion(.success(friends))
            }
    }
    
    func fetchFriendDetails(_ friend: Friendship, completion: @escaping (Result<FriendUser, Error>) -> Void) {
        let userRef = db.collection("users").document(friend.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "User not found", code: 404, userInfo: nil)))
                return
            }
            
            let username = document.get("username") as? String ?? "No username"
            let firstName = document.get("firstName") as? String ?? "Unknown"
            let lastName = document.get("lastName") as? String ?? "User"
            
            var friendDetails = FriendUser(uid: friend.uid, username: username, firstName: firstName, lastName: lastName, isPending: friend.isPending)
            
            // Returning the results as a tuple
            completion(.success(friendDetails))
        }
    }
        
    func fetchFriendDetails(usingId friendId: String, completion: @escaping (Result<FriendUser, Error>) -> Void) {
        let userRef = db.collection("users").document(friendId)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                completion(.failure(NSError(domain: "User not found", code: 404, userInfo: nil)))
                return
            }
            
            let username = document.get("username") as? String ?? "No username"
            let firstName = document.get("firstName") as? String ?? "Unknown"
            let lastName = document.get("lastName") as? String ?? "User"
            
            var friendDetails = FriendUser(uid: friendId, username: username, firstName: firstName, lastName: lastName, isPending: false)
            
            // Returning the results as a tuple
            completion(.success(friendDetails))
        }
    }
    
    func checkFriendExists(_ uid: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let friendCollection = userDbRef.collection("friends")
        
        friendCollection
                .document(uid)  // Reference the specific document by its ID
                .getDocument { (document, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    let isFriend = document?.exists ?? false  // Check if the document exists
                    completion(.success(isFriend))
                }
    }
    
    func checkUserExists(_ username: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let usersCollection = Firestore.firestore().collection("users")
        
        usersCollection
            .whereField("username", isEqualTo: username)
            .limit(to: 1)  // We only care if one match exists
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if querySnapshot!.documents.count > 0 {
                    completion(.success(querySnapshot!.documents[0].documentID))
                } else {
                    completion(.success(nil))
                }
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
    
    func sendRequest(_ requests: [Friendship], completion: @escaping (Result<Void, Error>) -> Void) {
        let requestToData = requests[0].toAnyObject()
        let requestFromData = requests[1].toAnyObject()
        
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let friendDbRef = db.collection("users").document(requests[0].uid)
        let myFriendsCollection = userDbRef.collection("friends")
        let otherFriendsCollection = friendDbRef.collection("friends")
        
        // Add a new document with an auto-generated ID and get the reference
        _ = myFriendsCollection.addDocument(data: requestToData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        _ = otherFriendsCollection.addDocument(data: requestFromData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        // Use the document reference to get the ID directly
        //let requestID = newDocumentRef.documentID  // Get the auto-generated ID
        completion(.success(()))  // Return the ID
    }
    
    func acceptFriendRequests(_ friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let friendDbRef = db.collection("users").document(friendId)

        let myFriendsCollection = userDbRef.collection("friends")
        let otherFriendsCollection = friendDbRef.collection("friends")

        let batch = db.batch()  // Use a batch for atomic operations

        // Helper function to update a document's "isPending" field
        func updatePendingStatus(from collection: CollectionReference, with id: String, completion: @escaping (Result<Void, Error>) -> Void
        ) {
            collection
                .whereField("uid", isEqualTo: id)
                .limit(to: 1)  // Fetch one document
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let document = querySnapshot?.documents.first else {
                        completion(.success(()))  // No document to update
                        return
                    }

                    batch.updateData(["isPending": false], forDocument: document.reference)  // Add update to batch
                    completion(.success(()))
                }
        }

        // First update in the user's friends collection
        updatePendingStatus(from: myFriendsCollection, with: friendId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                // Second update in the friend's friends collection
                updatePendingStatus(from: otherFriendsCollection, with: AppUser.shared.uid!) { otherResult in
                    switch otherResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        // Commit the batch after both updates are queued
                        batch.commit { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func deleteFriendRequests(_ friendId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let friendDbRef = db.collection("users").document(friendId)

        let myFriendsCollection = userDbRef.collection("friends")
        let otherFriendsCollection = friendDbRef.collection("friends")

        let batch = db.batch()  // Batch for atomic deletion

        // Helper to query and add the first matching document to the batch
        func addToBatch(from collection: CollectionReference, with id: String, completion: @escaping (Result<Void, Error>) -> Void) {
            collection
                .whereField("uid", isEqualTo: id)
                .limit(to: 1)  // Only need the first match
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard let document = querySnapshot?.documents.first else {
                        completion(.success(()))  // No match, nothing to delete
                        return
                    }

                    batch.deleteDocument(document.reference)  // Add to batch
                    completion(.success(()))
                }
        }

        // Fetch and delete from both collections
        addToBatch(from: myFriendsCollection, with: friendId) { myResult in
            switch myResult {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                addToBatch(from: otherFriendsCollection, with: AppUser.shared.uid!) { otherResult in
                    switch otherResult {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        // Commit the batch after adding all documents
                        batch.commit { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Function to add a task to Firestore using toAnyObject()
    func shareTask(_ task: Task, _ toId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let taskData = task.toAnyObjectWithId()  // Convert Task object to a dictionary
        let userDbRef = db.collection("users").document(toId)
        let tasksCollection = userDbRef.collection("sharedTasks")
        
        // Add a new document with an auto-generated ID and get the reference
        let newDocumentRef = tasksCollection.addDocument(data: taskData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
        }
        
        // Use the document reference to get the ID directly
        // let taskID = newDocumentRef.documentID  // Get the auto-generated ID
        completion(.success(()))  // Return the ID
    }
    
    func acceptTask(_ task: Task, completion: @escaping (Result<String, Error>) -> Void) {
        var newTaskId = ""
        let dispatchGroup = DispatchGroup()  // Create a dispatch group
        var errorOccurred: Error? = nil  // Track any error that occurs
        
        dispatchGroup.enter()
        addTask(task) { result in
            switch result {
            case .success(let taskId):
                newTaskId = taskId
            case .failure(let error):
                errorOccurred = error  // Capture the error
            }
            dispatchGroup.leave()  // Always leave the group
        }
        
        dispatchGroup.enter()
        rejectTask(taskId: task.id) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                errorOccurred = error  // Capture the error
            }
            dispatchGroup.leave()  // Always leave the group
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = errorOccurred {
                completion(.failure(error))  // Return the first error if any occurred
            } else {
                completion(.success(newTaskId))  // All tasks completed successfully
            }
        }
    }
    
    
    func rejectTask(taskId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userDbRef = db.collection("users").document(AppUser.shared.uid!)
        let tasksCollection = userDbRef.collection("sharedTasks")
        let taskRef = tasksCollection.document(taskId)
        
        taskRef.delete { error in
            if let error = error {
                completion(.failure(error)) // If there's an error, call the failure case
            } else {
                completion(.success(())) // Success case
            }
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
