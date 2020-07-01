//
//  TaskListViewController.swift
//  Lesson13HW1
//
//  Created by vaksakalov on 01.07.2020.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {

        private let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        private let cellID = "cell"
        private var tasks: [Task] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
            setupNavigationBar()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchData()
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
            showAlert(with: "New Task", and: "What do you want to do?")
        }
        
        private func showAlert(with title: String, and message: String) {
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
    }

    // MARK: - Core Data
    extension TaskListViewController {
        
        private func save(_ taskName: String) {
            guard let entityDescription = NSEntityDescription
                .entity(forEntityName: "Task", in: viewContext) else { return }
            guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
            task.name = taskName
            tasks.append(task)
            
            let indexPath = IndexPath(row: tasks.count - 1, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            do {
                try viewContext.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        private func fetchData() {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            
            do {
                tasks = try viewContext.fetch(fetchRequest)
            } catch let error {
                print(error)
            }
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
    }
