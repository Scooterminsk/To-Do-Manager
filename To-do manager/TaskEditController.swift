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

    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        // getting an actual value
        let title = taskTitle?.text ?? ""
        let type = taskType
        let status: TaskStatus = taskStatusSwitch.isOn ? .completed : .planned
        // calling the handler
        doAfterEdit?(title, type, status)
        // back to the previous screen
        navigationController?.popViewController(animated: true)
    }
}
