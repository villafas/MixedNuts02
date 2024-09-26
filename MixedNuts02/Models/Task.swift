//
//  Task.swift
//  MixedNuts02
//
//  Created by Default User on 3/18/24.
//

import Foundation
import Firebase

struct Task{
    
    //MARK: - Properties
    
    var id: String
    let title: String
    let course: String
    let notes: String?
    let dueDate: Date
    let markWeight: Int? // %
    let isComplete: Bool
    
    //MARK: - Constructors
    
    // Standard init
    init(id: String, title: String, course: String, notes: String?, dueDate: Date, markWeight: Int?, isComplete: Bool){
        self.id = id
        self.title = title
        self.course = course
        self.notes = notes
        self.dueDate = dueDate
        self.markWeight = markWeight
        self.isComplete = isComplete
    }
    
    // Init for reading from Database snapshot
    init(snapshot: QueryDocumentSnapshot) {
        id = snapshot.documentID
        title = snapshot.data()["title"] as! String
        course = snapshot.data()["course"] as! String
        notes = snapshot.data()["notes"] as? String
        dueDate = ((snapshot.data()["dueDate"]) as! Timestamp).dateValue()
        markWeight = snapshot.data()["markWeight"] as? Int
        isComplete = snapshot.data()["isComplete"] as! Bool
    }
    
    
    //MARK: - Conversion Methods
    
    // Func converting model for easier writing to database
    func toAnyObject() -> [String : Any] {
        return [
            "title": title,
            "course": course,
            "notes": notes ?? "",
            "dueDate": dueDate,
            "markWeight": markWeight ?? 0,
            "isComplete": isComplete
        ]
    }
    
}
