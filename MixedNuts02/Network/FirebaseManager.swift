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
    
}
