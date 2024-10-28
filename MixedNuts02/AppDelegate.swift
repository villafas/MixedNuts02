//
//  AppDelegate.swift
//  MixedNuts02
//
//  Created by Kevin Yuen on 2024-03-07.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import UserNotifications

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate {
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Database config
      // Initialize FirebaseManager which configures Firebase
      FirebaseApp.configure()
      _ = FirebaseManager.shared
      
      // Push notifs config
      UNUserNotificationCenter.current().delegate = self

      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      UNUserNotificationCenter.current().requestAuthorization(
        options: authOptions,				
        completionHandler: { _, _ in }
      )
      
      //Check if user is logged in
      Auth.auth().addStateDidChangeListener { auth, user in
          if let user = user {
              print("\(user.email!) is logged in.")
              
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
              let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController") as? UITabBarController
              
              // Set user information globally
              AppUser.shared.setUser(uid: user.uid, displayName: user.displayName, email: user.email)
              
              // Change root view controller
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController!)
              
              // Check if there is a pending notification
              if let pendingNotification = UserDefaults.standard.string(forKey: "PendingNotification") {
                  // Clear the saved notification
                  UserDefaults.standard.removeObject(forKey: "PendingNotification")
                  
                  (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setNotificationSelection(pendingNotification)
                  
                  // Navigate to TaskList
              }
          } else {
              print("There is no active user.")
          }
      }
      
      return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
    }
}

//MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate{
      // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo


        // notification presentation option
            return [[.list, .banner, .sound]]
      }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationInfo = response.notification.request.content.categoryIdentifier
        
        let appState = UIApplication.shared.applicationState
        print(appState.rawValue)
        if appState == .active || appState == .inactive {
            print("here")
            // App is in the foreground – navigate directly
            guard let tabBarController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController as? UITabBarController else {
                print("error")
                    return
                }

                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setNotificationSelection(notificationInfo, refresh: tabBarController.selectedIndex == 1 ? true : false)
            
        } else {
            // App is in the background or terminated – save notification info
            UserDefaults.standard.set(notificationInfo, forKey: "PendingNotification")
        }
        
        completionHandler()
    }
}
