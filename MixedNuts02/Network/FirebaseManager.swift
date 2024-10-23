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
    
    
    //MARK: - Fetch Users
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
    
    
    
    //MARK: - friend request
    func sendFriendRequest(from user1ID: String, to user2ID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendshipData: [String: Any] = [
            "user1ID": user1ID,
            "user2ID": user2ID,
            "status": "pending"
        ]
        
        db.collection("friendships").addDocument(data: friendshipData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    //MARK: - accept friend request
    // Function to accept a friend request
        func acceptFriendRequest(for friendshipID: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let docRef = db.collection("friendships").document(friendshipID)
            
            docRef.updateData(["status": "accepted"]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    
    
    //MARK: - fetch user's friends
    func fetchFriends(for userID: String, completion: @escaping (Result<[String], Error>) -> Void) {
        var friendIDs: [String] = []
        
        // Query friendships where the user is either user1ID or user2ID
        let group = DispatchGroup()
        
        // Fetch friends where user is user1ID
        group.enter()
        db.collection("friendships")
            .whereField("status", isEqualTo: "accepted")
            .whereField("user1ID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let friendID = data["user2ID"] as? String {
                            friendIDs.append(friendID)
                        }
                    }
                }
                group.leave()
            }
        
        // Fetch friends where user is user2ID
        group.enter()
        db.collection("friendships")
            .whereField("status", isEqualTo: "accepted")
            .whereField("user2ID", isEqualTo: userID)
            .getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let friendID = data["user1ID"] as? String {
                            friendIDs.append(friendID)
                        }
                    }
                }
                group.leave()
            }
        
        // Wait for both queries to finish
        group.notify(queue: .main) {
            completion(.success(friendIDs))
        }
    }
    
//    //MARK: - Fetch Pending Requests
//    func fetchPendingRequests(for userID: String, completion: @escaping (Result<[FriendUser], Error>) -> Void) {
//        db.collection("friendships")
//            .whereField("user2ID", isEqualTo: userID)
//            .whereField("status", isEqualTo: "pending")
//            .getDocuments { (snapshot, error) in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//                
//                var pendingUsers: [FriendUser] = []
//                for document in snapshot!.documents {
//                    let data = document.data()
//                    let senderID = data["user1ID"] as? String ?? ""
//                    
//                    // Fetch user details for the sender
//                    FirebaseManager.shared.fetchUser(with: senderID) { result in
//                        switch result {
//                        case .success(let user):
//                            pendingUsers.append(user)
//                            completion(.success(pendingUsers))
//                        case .failure(let error):
//                            print("Error fetching user: \(error.localizedDescription)")
//                        }
//                    }
//                }
//            }
//    }

    
//MARK: - Fetch (old code)
    
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
