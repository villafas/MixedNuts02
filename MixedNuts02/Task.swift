//
//  Task.swift
//  MixedNuts02
//
//  Created by Default User on 3/18/24.
//

import Foundation
import Firebase

//MARK: - Task Model
struct Task {
    var id: String
    let title: String
    let course: String
    let taskURL: String?
    let notes: String?
    let dueDate: Date
    let workDate: Date
    let isComplete: Bool
    
    // Standard init
    init(id: String, title: String, course: String, taskURL: String?, notes: String?, dueDate: Date, workDate: Date, isComplete: Bool){
        self.id = id
        self.title = title
        self.course = course
        self.taskURL = taskURL
        self.notes = notes
        self.dueDate = dueDate
        self.workDate = workDate
        self.isComplete = isComplete
    }
    
    // Init for reading from Database snapshot
    init(snapshot: QueryDocumentSnapshot) {
        id = snapshot.documentID
        title = snapshot.data()["title"] as! String
        course = snapshot.data()["course"] as! String
        taskURL = snapshot.data()["taskURL"] as? String
        notes = snapshot.data()["notes"] as? String
        dueDate = ((snapshot.data()["dueDate"]) as! Timestamp).dateValue();
        workDate = ((snapshot.data()["workDate"]) as! Timestamp).dateValue();
        isComplete = snapshot.data()["isComplete"] as! Bool
    }

    // Func converting model for easier writing to database
    func toAnyObject() -> [String : Any] {
        return [
            "title": title,
            "course": course,
            "taskURL": taskURL ?? "",
            "notes": notes ?? "",
            "dueDate": dueDate,
            "workDate": workDate,
            "isComplete": isComplete
        ]
    }
    
}
