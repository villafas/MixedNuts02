//
//  AppUser.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-04-18.
//

import Foundation
import Firebase

class AppUser {
    static let shared = AppUser()
    
    var uid: String?
    var displayName: String?
    var email: String?
    
    private init() {
        // Private init to prevent others from creating instances
    }
    
    func setUser(uid: String?, displayName: String?, email: String?) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
    }
    
    func clearUser() {
        self.uid = nil
        self.displayName = nil
        self.email = nil
    }
}
