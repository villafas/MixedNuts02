//
//  DaySchedule.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-18.
//

import Foundation

enum DayOfWeek: String, CaseIterable {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
}

class DaySchedule: Equatable {
    
    var day: DayOfWeek?
    var startTime: Time?
    var endTime: Time?
    var classroom: String?
    
    // MARK: - Standard init
    init(day: DayOfWeek? = nil, startTime: Time? = nil, endTime: Time? = nil, classroom: String? = nil) {
        self.day = day
        self.startTime = startTime
        self.endTime = endTime
        self.classroom = classroom
    }
    
    // MARK: - Initialize from Firestore dictionary
    init?(dictionary: [String: Any]) {
        guard
            let dayString = dictionary["day"] as? String,
            let day = DayOfWeek(rawValue: dayString),
            let startTimeDict = dictionary["startTime"] as? [String: Any],
            let endTimeDict = dictionary["endTime"] as? [String: Any],
            let classroom = dictionary["classroom"] as? String
        else {
            return nil
        }
        
        self.day = day
        self.startTime = Time(dictionary: startTimeDict)
        self.endTime = Time(dictionary: endTimeDict)
        self.classroom = classroom
    }
    
    // MARK: - Conversion to Dictionary
    func toDictionary() -> [String: Any] {
        guard let day = day,
              let startTime = startTime,
              let endTime = endTime,
              let classroom = classroom else {
            fatalError("DaySchedule: All fields must be present before converting to a dictionary")
        }
        
        return [
            "day": day.rawValue,
            "startTime": startTime.toDictionary(),
            "endTime": endTime.toDictionary(),
            "classroom": classroom
        ]
    }
    
    //MARK: -  Equatable
    static func == (lhs: DaySchedule, rhs: DaySchedule) -> Bool {
        return lhs.day == rhs.day &&
               lhs.startTime == rhs.startTime &&
               lhs.endTime == rhs.endTime &&
               lhs.classroom == rhs.classroom
    }
}
