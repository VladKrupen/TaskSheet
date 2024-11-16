//
//  CoreDataManager.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation
import CoreData
import Combine
import UIKit

protocol CoreDataSaving: AnyObject {
    func saveContext() throws
}

protocol CoreDataTasks: AnyObject {
    func createTasks(taskItems: [TaskItem]) -> AnyPublisher<Void, TaskError>
    func fetchTasks() -> AnyPublisher<[Task], TaskError>
}

final class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init() {
        self.persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        self.backgroundContext = persistentContainer.newBackgroundContext()
        self.backgroundContext.automaticallyMergesChangesFromParent = true
    }
}

//MARK: CoreDataSaving
extension CoreDataManager: CoreDataSaving {
    func saveContext() throws {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                throw TaskError.somethingWentWrong
            }
        }
    }
}

//MARK: CoreDataTasks
extension CoreDataManager: CoreDataTasks {
    func createTasks(taskItems: [TaskItem]) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self else { return }
            self.backgroundContext.perform {
                for item in taskItems {
                    let taskModel = TaskModel(context: self.backgroundContext)
                    taskModel.id = String(item.id)
                    taskModel.title = item.todo
                    taskModel.taskDescription = .init()
                    taskModel.completed = item.completed
                    taskModel.date = Date()
                }
                do {
                    try self.saveContext()
                    promise(.success(()))
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func fetchTasks() -> AnyPublisher<[Task], TaskError> {
        return Future<[Task], TaskError> { [weak self] promise in
            guard let self else { return }
            self.backgroundContext.perform {
                let fetchRequest = TaskModel.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
                do {
                    let tasksModel = try self.backgroundContext.fetch(fetchRequest)
                    var tasks: [Task] = []
                    for item in tasksModel {
                        tasks.append(Task(id: item.id ?? .init(),
                                          title: item.title ?? .init(),
                                          description: item.taskDescription ?? .init(),
                                          completed: item.completed,
                                          date: item.date ?? .init()))
                    }
                    promise(.success(tasks))
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
