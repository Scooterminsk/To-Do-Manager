//
//  TaskListController.swift
//  To-do manager
//
//  Created by Zenya Kirilov on 1.07.22.
//

import UIKit

class TaskListController: UITableViewController {

    // task storage
    var taskStorage: TaskStorageProtocol = TaskStorage()
    // task collection
    var tasks: [TaskPriority:[TaskProtocol]] = [:] {
        didSet {
            for (taskGroupPriority, taskGroup) in tasks {
                tasks[taskGroupPriority] = taskGroup.sorted { task1, task2 in
                    let task1position = tasksStatusPosition.firstIndex(of: task1.status) ?? 0
                    let task2position = tasksStatusPosition.firstIndex(of: task2.status) ?? 0
                    return task1position < task2position
                }
            }
        }
    }
    // the order in which tasks are displayed by their status
    var tasksStatusPosition: [TaskStatus] = [.planned, .completed]
    
    // display order of sections by its types
    // index in an array matches the index of a section in the table
    var sectionTypesPosition: [TaskPriority] = [.important, .normal]
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTasks()
    }

    private func loadTasks() {
        // preparing a collection with tasks
        // will use only those tasks for which a section is described in the table
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // loading and parsing of tasks from the storage
        taskStorage.loadTasks().forEach { task in
            tasks[task.type]?.append(task)
        }
    }
    // MARK: - Table view data source

    // number of sections in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    // number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // checking the priority of tasks matched with a current section
        let taskType = sectionTypesPosition[section]
        guard let currentTasksType = tasks[taskType] else {
            return 0
        }
        return currentTasksType.count
    }
    
    // a cell for row in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getConfiguratedTaskCell_stack(for: indexPath)
    }
    
    // setting title of sections
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String?
        let taskType = sectionTypesPosition[section]
        if taskType == .important {
            title = "Важные"
        } else if taskType == .normal {
            title = "Текущие"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // checking if the task exists
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return
        }
        
        // checking if the task isn't done
        guard tasks[taskType]![indexPath.row].status == .planned else {
            // cancelling mark from current line
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        // mark the line as done
        tasks[taskType]![indexPath.row].status = .completed
        // reload current table section
        tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
    }
    // a cell based on constraints
/*    private func getConfiguratedTaskCell_constraints(for indexPath: IndexPath) -> UITableViewCell {
        // loading a cell prototype by its identificator
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellConstraints", for: indexPath)
        // get data about the task we need to put into a cell
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
        
        // a symbol text label
        let symbolLabel = cell.viewWithTag(1) as? UILabel
        // a task name text label
        let textLabel = cell.viewWithTag(2) as? UILabel
        
        // changing a symbol in cell
        symbolLabel?.text = getSymbolForTask(with: currentTask.status)
        // changing a text in cell
        textLabel?.text = currentTask.title
        
        // changing text color and symbol
        if currentTask.status == .planned {
            textLabel?.textColor = .black
            symbolLabel?.textColor = .black
        } else {
            textLabel?.textColor = .lightGray
            symbolLabel?.textColor = .lightGray
        }
        
        return cell
    } */
    
    // a cell based on stack
    private func getConfiguratedTaskCell_stack(for indexPath: IndexPath) -> UITableViewCell {
        // loading a cell prototype by its identificator
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCellStack", for: indexPath) as! TaskCell
        // get data about the task we need to put into a cell
        let taskType = sectionTypesPosition[indexPath.section]
        guard let currentTask = tasks[taskType]?[indexPath.row] else {
            return cell
        }
       
        // changing a symbol in cell
        cell.symbol.text = getSymbolForTask(with: currentTask.status)
        // changing a text in cell
        cell.title.text = currentTask.title
        
        // changing text color and symbol
        if currentTask.status == .planned {
            cell.title.textColor = .black
            cell.symbol.textColor = .black
        } else {
            cell.title.textColor = .lightGray
            cell.symbol.textColor = .lightGray
        }
        
        return cell
        
    }
    
    // returning a symbol for a needed task type
    private func getSymbolForTask(with status: TaskStatus) -> String {
        var resultSymbol: String
        if status == .planned {
            resultSymbol = "\u{25CB}"
        } else if status == .completed {
            resultSymbol = "\u{25C9}"
        } else {
            resultSymbol = ""
        }
        return resultSymbol
    }
 
}
