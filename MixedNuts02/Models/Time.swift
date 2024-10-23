//
//  Time.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-18.
//

import Foundation

struct Time: Equatable, Comparable {
    var hour: Int
    var minute: Int
    
    // MARK: - Constructors
    
    // Standard init
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    // Init for reading from Firestore snapshot (Dictionary)
    init?(dictionary: [String: Any]) {
        guard
            let hour = dictionary["hour"] as? Int,
            let minute = dictionary["minute"] as? Int
        else {
            return nil
        }
        
        self.hour = hour
        self.minute = minute
    }
    
    // MARK: - Conversion Methods
    
    // Convert Time to dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "hour": hour,
            "minute": minute
        ]
    }
    
    // Convert Time to a Date object
    func toDate() -> Date? {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        // Use the current calendar to create a date
        let calendar = Calendar.current
        return calendar.date(from: components)
    }
    
    // Convert Time to a Date object with today's date
    func toTodaysDate() -> Date? {
        let calendar = Calendar.current
        let today = Date()
        
        // Get the current year, month, and day from today's date
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        // Set the hour and minute from the Time object
        var components = DateComponents()
        components.year = todayComponents.year
        components.month = todayComponents.month
        components.day = todayComponents.day
        components.hour = self.hour
        components.minute = self.minute
        
        // Create a date with today's date and the time from the Time object
        return calendar.date(from: components)
    }
    
    
    // Convert Date back to Time
    static func fromDate(_ date: Date) -> Time {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return Time(hour: hour, minute: minute)
    }
    
    //MARK: - Comparable conformance
    // Implement the < operator for Comparable conformance
    static func < (lhs: Time, rhs: Time) -> Bool {
        if lhs.hour == rhs.hour {
            return lhs.minute < rhs.minute
        }
        return lhs.hour < rhs.hour
    }
}
