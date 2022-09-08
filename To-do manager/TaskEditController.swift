//
//  TaskEditController.swift
//  To-do manager
//
//  Created by Zenya Kirilov on 26.07.22.
//

import UIKit

class TaskEditController: UITableViewController {

    // parameters of the task
    var taskText: String = ""
    var taskType: TaskPriority = .normal
    var taskStatus: TaskStatus = .planned
    
    // names of task types
    private var taskTitles: [TaskPriority: String] = [
        .important: "Важная",
        .normal: "Текущая"
    ]
    
    var doAfterEdit: ((String, TaskPriority, TaskStatus) -> Void)?
    
    @IBOutlet var taskTitle: UITextField!
    @IBOutlet var taskTypeLabel: UILabel!
    @IBOutlet var taskStatusSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // updating the text field with the name of the task
        taskTitle?.text = taskText
        // updating the label according to the current type
        taskTypeLabel?.text = taskTitles[taskType]
        // updating task status
        if taskStatus == .completed {
            taskStatusSwitch.isOn = true
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    // MARK: - Did select row at IndexPath
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row != 2 else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }
    // MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toTaskTypeScreen" {
            // a reference for destination controller
            let destination = segue.destination as! TaskTypeController
            // transfering chosen type
            destination.selectedType = taskType
            // transfeting a type handler
            destination.doAfterTypeSelected = { [unowned self] selectedType in
                taskType = selectedType
                // updating the label with current type
                taskTypeLabel?.text = taskTitles[taskType]
            }
        }
    }
    // MARK: - Action method for tasks saving
    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        // getting an actual value
        var title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        // do the check and if its true call the handler
        if !taskTitle.hasText {
            let alert = UIAlertController(title: "Введите название задачи!", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Назад", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
        } else if taskTitle.text?.first == " " {
            title = taskTitle.text?.trimmingCharacters(in: .whitespaces) ?? ""
            doAfterEdit?(title, type, status)
            // back to the previous screen
            navigationController?.popViewController(animated: true)
        } else {
            doAfterEdit?(title, type, status)
            navigationController?.popViewController(animated: true)
        }
    }
}
