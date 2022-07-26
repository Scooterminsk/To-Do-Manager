//
//  TaskTypeController.swift
//  To-do manager
//
//  Created by Zenya Kirilov on 26.07.22.
//

import UIKit

class TaskTypeController: UITableViewController {

    // 1. a touple that will describe a task type
    typealias TypeCellDescription = (type: TaskPriority, title: String, description: String)
    
    // 2. collection of available task types with their descriptions
    private var taskTypesInformation: [TypeCellDescription] = [
        (type: .important, title: "Важная", description: "Такой тип задачи является наиболее приоритетным для выполнения. Все важные задачи выводятся в самом верху списка задач"),
        (type: .normal, title: "Текущая", description: "Задача с обычным приоритетом")
        ]
    
    // 3. selected priority
    var selectedType: TaskPriority = .normal
    
    // type choosing handler
    var doAfterTypeSelected: ((TaskPriority) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. getting a value of the UINib type, corresponding to a xib-file of the custom cell
        let cellTypeNib = UINib(nibName: "TaskTypeCell", bundle: nil)
        // 2. registration of the custom cell in the table view
        tableView.register(cellTypeNib, forCellReuseIdentifier: "TaskTypeCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskTypesInformation.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1. getting a reusable custom cell by its identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTypeCell", for: indexPath) as! TaskTypeCell
        
        // 2. getting a current element, for which information information have to be outputed in line
        let typeDescription = taskTypesInformation[indexPath.row]
        
        // 3. filling a cell with data
        cell.typeTitle.text = typeDescription.title
        cell.typeDescription.text = typeDescription.description
        
        // 4. if the type is selected, will mark it with check
        if selectedType == typeDescription.type {
            cell.accessoryType = .checkmark
            // in anothe case will cancel the mark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // getting chosen type
        let selectedType = taskTypesInformation[indexPath.row].type
        // calling the handler
        doAfterTypeSelected?(selectedType)
        // back to previous screen
        navigationController?.popViewController(animated: true)
    }
}
