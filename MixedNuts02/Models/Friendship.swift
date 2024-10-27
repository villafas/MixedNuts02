//
//  FriendRequest.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-26.
//

import Foundation
import FirebaseFirestore

struct Friendship {
    
    // MARK: - Properties
    
    var uid: String
    let isSender: Bool
    var isPending: Bool
    
    // MARK: - Constructors
    
    // Standard init
    init(uid: String, isSender: Bool, isPending: Bool) {
        self.uid = uid
        self.isSender = isSender
        self.isPending = isPending
    }
    
    // Init for reading from Database snapshot
    init(snapshot: QueryDocumentSnapshot) {
        uid = snapshot.data()["uid"] as! String
        isSender = snapshot.data()["isSender"] as! Bool
        isPending = snapshot.data()["isPending"] as! Bool
    }
    
    // MARK: - Conversion Methods
    
    // Func converting model for easier writing to database
    func toAnyObject() -> [String: Any] {
        return [
            "uid": uid,
            "isSender": isSender,
            "isPending": isPending
        ]
    }
}
