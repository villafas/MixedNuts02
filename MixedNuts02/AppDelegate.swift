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
      
      // Check if a user is logged in
      Auth.auth().addStateDidChangeListener { auth, user in
          if let user = user {
              print("\(user.email!) is logged in.")
              print(user)
              let storyboard = UIStoryboard(name: "Main", bundle: nil)
              let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController") as? UITabBarController
              
              // Set user information globally
              AppUser.shared.setUser(uid: user.uid, displayName: user.displayName, email: user.email)
              // This is to get the SceneDelegate object from your view controller
              // then call the change root view controller function to change to main tab bar
              (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController!)
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

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Logic for when a notification is selected
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController") as? UITabBarController
        mainTabBarController?.selectedIndex = 1
        // This is to get the SceneDelegate object from your view controller
        // then call the change root view controller function to change to main tab bar
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController!)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.setNotificationSelection(response.notification.request.content.categoryIdentifier)
        
        completionHandler()
    }
}
