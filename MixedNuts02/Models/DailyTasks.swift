//
//  DaySection.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-10.
//

import Foundation

struct DailyTasks {
    var day: Date
    var tasks: [Task]
    
    init(day: Date , tasks: [Task]){
        self.day = day
        self.tasks = tasks
    }
}