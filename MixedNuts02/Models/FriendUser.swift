//
//  FriendRequest.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation

struct FriendUser {
    
    // MARK: - Properties
    
    var uid: String
    let username: String
    let firstName: String
    let lastName: String
    let isPending: Bool?
    
    // MARK: - Constructors
    
    // Standard init
    init(uid: String, username: String, firstName: String, lastName: String, isPending: Bool = false) {
        self.uid = uid
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.isPending = isPending
    }
}
