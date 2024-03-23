//
//  Task.swift
//  MixedNuts02
//
//  Created by Default User on 3/18/24.
//

import Foundation
import Firebase

struct Task {
    let title: String
    let course: String
    let dueDate: Date
    let workDate: Date
    let isComplete: Bool
    
    // Standard init
    init(title: String, course: String, dueDate: Date, workDate: Date, isComplete: Bool){
        self.title = title
        self.course = course
        self.dueDate = dueDate
        self.workDate = workDate
        self.isComplete = isComplete
    }
    
    // Init for reading from Database snapshot
    init(snapshot: QueryDocumentSnapshot) {
        title = snapshot.data()["title"] as! String
        course = snapshot.data()["course"] as! String
        dueDate = ((snapshot.data()["dueDate"]) as! Timestamp).dateValue();
        workDate = ((snapshot.data()["workDate"]) as! Timestamp).dateValue();
        isComplete = snapshot.data()["isComplete"] as! Bool
    }

    // Func converting model for easier writing to database
    func toAnyObject() -> [String : Any] {
        return [
            "title": title,
            "course": course,
            "dueDate": dueDate,
            "workDate": workDate,
            "isComplete": isComplete
        ]
    }
    
}
