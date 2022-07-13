//
//  Task.swift
//  To-do manager
//
//  Created by Zenya Kirilov on 1.07.22.
//

import Foundation

// task type
enum TaskPriority {
    // current
    case normal
    // important
    case important
}

// task's condition
enum TaskStatus {
    // planned
    case planned
    // completed
    case completed
}

// requirements for the type describing the entity 'Task'
protocol TaskProtocol {
    // title
    var title: String { get set }
    // type
    var type: TaskPriority { get set }
    // status
    var status: TaskStatus { get set }
}

// the entity 'Task'
struct Task: TaskProtocol {
    var title: String
    var type: TaskPriority
    var status: TaskStatus
}

