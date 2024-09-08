//
//  CollectionReference+Extensions.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-04.
//

import Foundation
import Firebase

extension CollectionReference {
    func whereField(_ field: String, isDateEqual value: DateComponents) -> Query {
        //let components = Calendar.current.dateComponents([.year, .month, .day], from: value)
        guard
            let start = Calendar.current.date(from: value),
            let end = Calendar.current.date(byAdding: .day, value: 1, to: start)
        else {
            fatalError("Could not find start date or calculate end date.")
        }
        return whereField(field, isGreaterThan: start).whereField(field, isLessThan: end)
    }
}
