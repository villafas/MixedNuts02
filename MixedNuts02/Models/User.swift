//
//  User.swift
//  MixedNuts02
//
//  Created by Kevin Yuen on 2024-03-28.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
    init(authData: Firebase.User){
        self.uid = authData.uid
        self.email = authData.email!
    }
}
