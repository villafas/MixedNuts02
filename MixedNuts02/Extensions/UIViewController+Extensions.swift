//
//  UIViewController+Extensions.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation
import UIKit

// Put this piece of code anywhere you like
extension UIViewController {
    // allow keyboards to be tapped out of
    
    //MARK: - Keyboard dismissal
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: - Notification Logic
    
    // sample for testing
    func scheduleNotification(taskObj: Task) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Don't forget to complete \(taskObj.title)!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "\(taskObj.id)"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: "Temp", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    // sample for testing
    func sampleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "YOU'RE 2 WEEKS LATE!?"
        content.body = "Hurry up and submit PPP 5!"
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = "OWzmE20GfPngZo429Y0i"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

        let request = UNNotificationRequest(identifier: "Temp", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    // schedule the different notification times
    func scheduleNotifications(taskObj: Task){
        // Define time intervals
        let intervals: [TimeInterval] = [-3*24*60*60,
        -1*24*60*60, -12*60*60, -1*60*60, -1*60, 1*60]
        // 3 days before, 1 day before, 12 hours before, 1 hour before, 1 minute before, 1 minute after
        
        for interval in intervals {
            var content: UNMutableNotificationContent?
            var triggerDate: Date?
            var trigger: UNCalendarNotificationTrigger?
            var request: UNNotificationRequest?
            if interval == -3*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "3 Days Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_3D", content: content!, trigger: trigger)
            } else if interval == -1*24*60*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Day Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
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
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1H", content: content!, trigger: trigger)
            } else if interval == -1*60 {
                content = UNMutableNotificationContent()
                content!.title = "1 Minute Left"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1M", content: content!, trigger: trigger)
            } else if interval == 1*60 {
                content = UNMutableNotificationContent()
                content!.title = "You missed it"
                content!.body = "Don't forget to complete \(taskObj.title)!"
                content!.sound = UNNotificationSound.default
                content!.categoryIdentifier = "\(taskObj.id)"
                triggerDate = Calendar.current.date(byAdding: .second, value: Int(interval), to: taskObj.dueDate)!
                
                trigger = UNCalendarNotificationTrigger(
                    dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!), repeats: false)
                request = UNNotificationRequest(identifier: "\(taskObj.id)_1L", content: content!, trigger: trigger)
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
    
    func deleteNotifications(taskId: String, deletePending: Bool){
        let idExtensions: [String] = ["\(taskId)_3D", "\(taskId)_1D", "\(taskId)_12H", "\(taskId)_1H", "\(taskId)_1M", "\(taskId)_1L"]

        if deletePending {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: idExtensions)
        }
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: idExtensions)
    }
}
