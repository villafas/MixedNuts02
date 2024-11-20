//
//  Task.swift
//  MixedNuts02
//
//  Created by Default User on 3/18/24.
//

import Foundation
import Firebase

struct TaskToDo: Codable{
    
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
    
    func toAnyObjectWithId() -> [String : Any] {
        return [
            "uid": id,
            "title": title,
            "course": course,
            "notes": notes ?? "",
            "dueDate": dueDate,
            "markWeight": markWeight ?? 0,
            "isComplete": isComplete
        ]
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id, title, course, notes, dueDate, markWeight, isComplete
    }

    // MARK: - Custom Decoding Logic
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        course = try container.decode(String.self, forKey: .course)
        notes = try? container.decode(String.self, forKey: .notes)
        markWeight = try? container.decode(Int.self, forKey: .markWeight)
        isComplete = try container.decode(Bool.self, forKey: .isComplete)
        
        // Handle dueDate as either a timestamp or string-based date
        if let timestamp = try? container.decode(Double.self, forKey: .dueDate) {
            dueDate = Date(timeIntervalSince1970: timestamp)
        } else if let dateString = try? container.decode(String.self, forKey: .dueDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0) // Ensure it's parsed as UTC
            
            if let date = formatter.date(from: dateString) {
                dueDate = date
            } else {
                // Handle fallback to ISO8601 format if the first fails
                let isoFormatter = ISO8601DateFormatter()
                guard let isoDate = isoFormatter.date(from: dateString) else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .dueDate,
                        in: container,
                        debugDescription: "Invalid date format: \(dateString)"
                    )
                }
                dueDate = isoDate
            }
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .dueDate,
                in: container,
                debugDescription: "Expected date to be a timestamp or a valid date string."
            )
        }
    }

    
}
