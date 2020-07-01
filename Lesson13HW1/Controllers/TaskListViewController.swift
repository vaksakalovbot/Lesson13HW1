//
//  TaskListViewController.swift
//  Lesson13HW1
//
//  Created by vaksakalov on 01.07.2020.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit

class TaskListViewController: UITableViewController {
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        setupRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tasks = StorageManager.shared.fetchData()
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addTask() {
        showAlertAddTask(with: "New Task", and: "What do you want to do?")
    }
    
    private func showAlertAddTask(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField()
        
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        if let task = StorageManager.shared.addNewTask(taskName) {
            tasks.append(task)
            let indexPath = IndexPath(row: tasks.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    private func update(_ taskName: String, indexPath: IndexPath) {
        if let task = StorageManager.shared.updateSelectedTask(tasks[indexPath.row], taskName) {
            tasks[indexPath.row] = task
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(updateView), for: .valueChanged)
        tableView.addSubview(refreshControl ?? UIRefreshControl())
    }
    
    @objc private func updateView() {
        tasks = StorageManager.shared.fetchData()
        refreshControl?.endRefreshing()
        tableView.reloadData()
    }

}

// MARK: - Table view data source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showDetailInfoAboutTask(at: indexPath)
    }
    
    private func showDetailInfoAboutTask(at indexPath: IndexPath) {
        print(tasks[indexPath.row])
    }
        
    // MARK: - Delete or update on swipe
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
                
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (_, _, completionHandler) in
            self.showActionSheetForDeleteTask(withTitle: self.tasks[indexPath.row].name ?? "", andMessage: "Delete?", indexPath: indexPath)
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red
        
        let updateAction = UIContextualAction(style: .normal, title: "Rename") {  (_, _, completionHandler) in
            self.showAlertUpdateTask(with: "Rename task", and: "Enter new task name:", indexPath: indexPath)
            completionHandler(true)
        }
        updateAction.backgroundColor = .blue
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction, updateAction])
        swipeActions.performsFirstActionWithFullSwipe = false

        return swipeActions
    }
    
    private func showActionSheetForDeleteTask(withTitle title: String, andMessage message: String, indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in

            if StorageManager.shared.removeSelectedTask(self.tasks[indexPath.row]) {
                self.tasks.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
        }
        let noAction = UIAlertAction(title: "No", style: .cancel)
        actionSheet.addAction(yesAction)
        actionSheet.addAction(noAction)
        
        present(actionSheet, animated: true)
    }
    
    private func showAlertUpdateTask(with title: String, and message: String, indexPath: IndexPath) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Rename", style: .default) { _ in
            guard let taskName = alert.textFields?.first?.text, !taskName.isEmpty else { return }
            self.update(taskName, indexPath: indexPath)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.text = self.tasks[indexPath.row].name
        }

        present(alert, animated: true)
    }
    
}
