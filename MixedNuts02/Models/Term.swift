//
//  Term.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-18.
//

import Foundation
import Firebase

struct Term{
    
    //MARK: - Properties
    
    let id: String
    let caption: String
    let season: String
    let year: Int
    let startDate: Date
    let endDate: Date
    
    //MARK: - Constructors
    
    // Standard init
    init(id: String, caption: String, season: String, year: Int, startDate: Date, endDate: Date) {
        self.id = id
        self.caption = caption
        self.season = season
        self.year = year
        self.startDate = startDate
        self.endDate = endDate
    }
    
    // Init for reading from Database snapshot
    init(snapshot: QueryDocumentSnapshot) {
        id = snapshot.documentID
        caption = snapshot.data()["caption"] as! String
        season = snapshot.data()["season"] as! String
        year = snapshot.data()["year"] as! Int
        startDate = ((snapshot.data()["startDate"]) as! Timestamp).dateValue()
        endDate = ((snapshot.data()["endDate"]) as! Timestamp).dateValue()
    }
    
    //MARK: - Conversion Methods
    
    // Func converting model for easier writing to database
    func toAnyObject() -> [String : Any] {
        return [
            "caption": caption,
            "season": season,
            "year": year,
            "startDate": startDate,
            "endDate": endDate
        ]
    }
    
}
