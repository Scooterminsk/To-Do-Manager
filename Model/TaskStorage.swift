//
//  TaskStorage.swift
//  To-do manager
//
//  Created by Zenya Kirilov on 1.07.22.
//

import Foundation

// the protocol describing the entity 'Data storage'
protocol TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol]
    func saveTasks(_ tasks: [TaskProtocol])
}

// the entity 'Data storage'
class TaskStorage: TaskStorageProtocol {
    func loadTasks() -> [TaskProtocol] {
        // temporary implementation returning test task collection
        let testTasks: [TaskProtocol] = [
            Task(title: "Купить хлеб", type: .normal, status: .planned),
            Task(title: "Помыть кота", type: .important, status: .planned),
            Task(title: "Отдать долг арнольду", type: .important, status: .completed),
            Task(title: "Купить новый пылесос", type: .normal, status: .completed),
            Task(title: "Подарить цветы супруге", type: .important, status: .planned),
            Task(title: "Позвонить родителям", type: .important, status: .planned)
        ]
        return testTasks
    }
    
    func saveTasks(_ tasks: [TaskProtocol]) {}
}
