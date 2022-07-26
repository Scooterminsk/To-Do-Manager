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
                
                // saving tasks
                var savingArray: [TaskProtocol] = []
                tasks.forEach { _, value in
                    savingArray += value
                }
                taskStorage.saveTasks(savingArray)
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
        // tasks loading
        loadTasks()
        // task editing mode activation button
        navigationItem.leftBarButtonItem = editButtonItem
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
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // getting data about a task, which is needed to switch to the planned status
        let taskType = sectionTypesPosition[indexPath.section]
        guard let _ = tasks[taskType]?[indexPath.row] else {
            return nil
        }
        
        // creating an action to change status
        let actionSwipeInstance = UIContextualAction(style: .normal, title: "Не выполнена") { _, _, _ in
            self.tasks[taskType]![indexPath.row].status = .planned
            self.tableView.reloadSections(IndexSet(arrayLiteral: indexPath.section), with: .automatic)
        }
        
        // action for transition to an edit screen
        let actionEditInstance = UIContextualAction(style: .normal, title: "Изменить") { _, _, _ in
            // loading a scene from storyboard
            let editScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TaskEditController") as! TaskEditController
            // transfering values of the editing task
            editScreen.taskText = self.tasks[taskType]![indexPath.row].title
            editScreen.taskType = self.tasks[taskType]![indexPath.row].type
            editScreen.taskStatus = self.tasks[taskType]![indexPath.row].status
            // transfering a handler for saving a task
            editScreen.doAfterEdit = { [unowned self] title, type, status in
                let editedTask = Task(title: title, type: type, status: status)
                tasks[taskType]![indexPath.row] = editedTask
                tableView.reloadData()
            }
            // transition to the edit screen
            self.navigationController?.pushViewController(editScreen, animated: true)
        }
        // changing color of a button with action
        actionEditInstance.backgroundColor = .darkGray
        
        // creating an object that will describe actions; depending on task status it will be showed 1 or 2 actions
        let actionConfiguration: UISwipeActionsConfiguration
        if tasks[taskType]![indexPath.row].status == .completed {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionSwipeInstance, actionEditInstance])
        } else {
            actionConfiguration = UISwipeActionsConfiguration(actions: [actionEditInstance])
        }
        
        return actionConfiguration
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let taskType = sectionTypesPosition[indexPath.section]
        // deleting the task
        tasks[taskType]?.remove(at: indexPath.row)
        // delete a row matching with current task
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // source section
        let taskTypeFrom = sectionTypesPosition[sourceIndexPath.section]
        // destination section
        let taskTypeTo = sectionTypesPosition[destinationIndexPath.section]
        
        // safe unwrapping of the task ang copying it
        guard let movedTask = tasks[taskTypeFrom]?[sourceIndexPath.row] else {
            return
        }
        
        // deleting the task from the place from where it was transferred
        tasks[taskTypeFrom]!.remove(at: sourceIndexPath.row)
        // pasting the task into the new position
        tasks[taskTypeTo]!.insert(movedTask, at: destinationIndexPath.row)
        // if the section is changed, will change a type of the task according to the new position
        if taskTypeFrom != taskTypeTo {
            tasks[taskTypeTo]![destinationIndexPath.row].type = taskTypeTo
        }
        
        // updating data
        tableView.reloadData()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCreateScreen" {
            let destination = segue.destination as! TaskEditController
            destination.doAfterEdit = { [unowned self] title, type, status in
                let newTask = Task(title: title, type: type, status: status)
                tasks[type]?.append(newTask)
                tableView.reloadData()
            }
        }
    }
    
    // getting task list their checking and loading to the task property
    func setTasks(_ taskCollection: [TaskProtocol]) {
        // preparation of the collection with tasks
        // will use only those tasks for witch a section is chosen
        sectionTypesPosition.forEach { taskType in
            tasks[taskType] = []
        }
        // loading and checking tasks from the storage
        taskCollection.forEach { task in
            tasks[task.type]?.append(task)
        }
        
    }
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
