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
    
    
    //MARK: - Constructors
    
    private init() {
        // Private init to prevent others from creating instances
        //FirebaseApp.configure()
    }
    
    
    //MARK: - Methods
    
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
    
    //Created by Gavin Shaw - September 16
    
    //Method is created to fetch all users from the Firebase db
    func fetchUsers(completion: @escaping (Result<[FriendUser], Error>) -> Void) {
            db.collection("users").getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                var users: [FriendUser] = []
                for document in querySnapshot!.documents {
                    let user = FriendUser(snapshot: document)
                    users.append(user)
                }
                completion(.success(users))
            }
        }
    
    
    //Update Exisiting User
//    func updateUser(_ user: AppUser, completion: @escaping (Error?) -> Void) {
//        // Unwrap user.uid safely
//        guard let userId = user.uid else {
//            completion(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User ID is nil"]))
//            return
//        }
//        
//        let userRef = db.collection("users").document(userId)
//        userRef.updateData(user.toAnyObject()) { error in
//            completion(error)
//        }
//    }

    
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
}
