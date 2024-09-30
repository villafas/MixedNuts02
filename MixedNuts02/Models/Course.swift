//
//  Course.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-12.
//

import Foundation
import Firebase

struct Course {
    
    //MARK: - Properties
    
    var id: String
    let title: String
    let code: String
    let schedule: [DaySchedule]
    let term: String
    let prof: String?
    let courseURL: String?
    
    //MARK: - Constructors
    
    // Standard init
    init(id: String, title: String, code: String, schedule: [DaySchedule], term: String, prof: String?, courseURL: String?) {
        self.id = id
        self.title = title
        self.code = code
        self.schedule = schedule
        self.term = term
        self.prof = prof
        self.courseURL = courseURL
    }
    
    // Init for reading from Firestore snapshot
    init(snapshot: QueryDocumentSnapshot) {
        id = snapshot.documentID
        title = snapshot.data()["title"] as! String
        code = snapshot.data()["code"] as! String
        
        let scheduleArray = snapshot.data()["schedule"] as! [[String: Any]]
        schedule = scheduleArray.compactMap { DaySchedule(dictionary: $0) }
        
        term = snapshot.data()["term"] as! String
        prof = snapshot.data()["prof"] as? String
        courseURL = snapshot.data()["courseURL"] as? String
    }
    
    //MARK: - Conversion Methods
    
    // Func converting model for easier writing to Firestore
    func toAnyObject() -> [String: Any] {
        return [
            "title": title,
            "code": code,
            "schedule": schedule.map { $0.toDictionary() },
            "term": term,
            "prof": prof ?? "",
            "courseURL": courseURL ?? ""
        ]
    }
}
