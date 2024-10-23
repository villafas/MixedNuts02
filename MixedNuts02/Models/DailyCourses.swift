//
//  DailyCourses.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-10-22.
//

import Foundation

struct DailyCourses {
    var weekday: DayOfWeek
    var courses: [Course]
    
    init(weekday: DayOfWeek , courses: [Course]){
        self.weekday = weekday
        self.courses = courses
    }
}
