//
//  AppUser.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-04-18.
//

import Foundation
import Firebase

class AppUser {
    
    //MARK: - Properties
    
    static let shared = AppUser() // make available globally
    
    var uid: String?
    var displayName: String?
    var email: String?
    
    // MARK: - Initializers
    
    init(snapshot: QueryDocumentSnapshot) {
        
        let data = snapshot.data()
        self.uid = snapshot.documentID
        self.displayName = data["displayName"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? "No Email"
        
    }
    
    //MARK: -  Constructors
    
    private init() {
        // Private init to prevent others from creating instances
    }
    
    
    //MARK: - Methods
    
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
