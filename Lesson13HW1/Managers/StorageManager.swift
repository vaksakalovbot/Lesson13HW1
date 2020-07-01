//
//  StorageManager.swift
//  Lesson13HW1
//
//  Created by vaksakalov on 01.07.2020.
//  Copyright © 2020 Vladimir. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack

    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Lesson13HW1")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    private init() {}
    
    func fetchData() -> [Task]{
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        var tasks: [Task] = []
        
        do {
            tasks = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error {
            print(error)
        }
        
        return tasks
    }
    
    func addNewTask(_ taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription
            .entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return nil}
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return nil}
        task.name = taskName

        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return task
    }

    func updateSelectedTask(_ taskName: String) -> Task? {
        guard let entityDescription = NSEntityDescription
            .entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return nil}
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return nil}
        task.name = taskName
        
        do {
            try persistentContainer.viewContext.save()
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        return task
    }

    func removeSelectedTask(_ taskName: String) -> Bool {
        print(#function)
        return true
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
