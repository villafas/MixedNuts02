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
