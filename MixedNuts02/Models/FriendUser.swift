//
//  FriendUser.swift
//  MixedNuts02
//
//  Created by Gavin Shaw on 2024-09-24.
//

import Foundation
import Firebase

class FriendUser {
    
    //MARK: - Properties
    
    var uid: String?
    var displayName: String?
    var email: String?
    
    // MARK: - Initializers
    
    init(snapshot: QueryDocumentSnapshot) {
        
        let data = snapshot.data()
        self.uid = snapshot.documentID
        self.displayName = data["name"] as? String ?? "No Name"
        self.email = data["email"] as? String ?? "No Email"
        
    }
    
    //MARK: -  Constructors
    
    private init() {
        // Private init to prevent others from creating instances
    }
}
