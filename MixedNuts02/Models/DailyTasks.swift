//
//  DaySection.swift
//  MixedNuts02
//
//  Created by Sebastian on 2024-09-10.
//

import Foundation

struct DailyTasks {
    var day: Date
    var tasks: [TaskToDo]
    
    init(day: Date , tasks: [TaskToDo]){
        self.day = day
        self.tasks = tasks
    }
}

struct SharedTask {
    var user: FriendUser
    var task: TaskToDo
    
    init(user: FriendUser, task: TaskToDo) {
        self.user = user
        self.task = task
    }
}
