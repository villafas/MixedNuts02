//
//  NotificationHelper.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-21.
//

import Foundation
import UserNotifications

struct NotificationHelper {
    //MARK: - Notification Logic
    
    static func scheduleNotifications(taskObj: Task, intervals: [TimeInterval]) {
        if intervals.isEmpty{
            return
        }
        
        for interval in intervals {
            var content: UNMutableNotificationContent?
            var triggerDate: Date?
            var trigger: UNCalendarNotificationTrigger?
            var request: UNNotificationRequest?
            if interval == -3*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "3 Days Left"
                content!.body = "The due date is coming up for \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_3D", content: content!, trigger: trigger)
            } else if interval == -1*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Day Left"
                content!.body = "You have 24 hours to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1D", content: content!, trigger: trigger)
            } else if interval == -12*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "12 Hours Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_12H", content: content!, trigger: trigger)
            } else if interval == -1*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Hour Left"
                content!.body = "Did you complete \(taskObj.title)?"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1H", content: content!, trigger: trigger)
            }
            
            UNUserNotificationCenter.current().add(request!) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                } else {
                    //print("Notification scheduled successfully")
                }
            }
        }
    }
    
    static func deleteNotifications(taskId: String, deletePending: Bool){
        let idExtensions: [String] = ["\(taskId)_3D", "\(taskId)_1D", "\(taskId)_12H", "\(taskId)_1H"]
        print(idExtensions)
        if deletePending {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idExtensions)
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idExtensions)
    }
    
    static func findNotifications(withIDs ids: [String], completion: @escaping ([String]) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests { requests in
            // Filter the requests to find matching IDs
            print(requests)
            let matchingIDs = requests
                .filter { ids.contains($0.identifier) }
                .map { $0.identifier }
            
            completion(matchingIDs)  // Return the list of found IDs
        }
    }
}
