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

protocol CoreDataTaskProvider: AnyObject {
    func createTasks(taskItems: [TaskItem]) -> AnyPublisher<Void, TaskError>
    func fetchTasks() -> AnyPublisher<[Task], TaskError>
}

protocol CoreDataUpdatingTask: AnyObject {
    func updateTask(task: Task) -> AnyPublisher<Void, TaskError>
}

protocol CoreDataCreationTask: AnyObject {
    func createTask(task: Task) -> AnyPublisher<Void, TaskError>
}

protocol CoreDataDeletingTask: AnyObject {
    func deleteTask(task: Task) -> AnyPublisher<Void, TaskError>
}

final class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    init(persistentContainer container: NSPersistentContainer? = nil) {
        if let container {
            self.persistentContainer = container
        } else {
            self.persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        }
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

//MARK: CoreDataTaskProvider
extension CoreDataManager: CoreDataTaskProvider {
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

//MARK: CoreDataUpdatingTask
extension CoreDataManager: CoreDataUpdatingTask {
    func updateTask(task: Task) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self else { return }
            self.backgroundContext.perform {
                let fetchRequest = TaskModel.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
                do {
                    let tasksModel = try self.backgroundContext.fetch(fetchRequest)
                    guard let taskModel = tasksModel.first else { return }
                    taskModel.title = task.title
                    taskModel.taskDescription = task.description
                    taskModel.completed = task.completed
                    try self.saveContext()
                    promise(.success(()))
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

//MARK: CoreDataCreationTask
extension CoreDataManager: CoreDataCreationTask {
    func createTask(task: Task) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self else { return }
            self.backgroundContext.perform {
                let taskModel = TaskModel(context: self.backgroundContext)
                taskModel.id = task.id
                taskModel.title = task.title
                taskModel.taskDescription = task.description
                taskModel.completed = task.completed
                taskModel.date = task.date
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
}

//MARK: CoreDataDeletingTask
extension CoreDataManager: CoreDataDeletingTask {
    func deleteTask(task: Task) -> AnyPublisher<Void, TaskError> {
        return Future<Void, TaskError> { [weak self] promise in
            guard let self else { return }
            self.backgroundContext.perform {
                let fetchRequest = TaskModel.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "id == %@", task.id)
                do {
                    let tasksModel = try self.backgroundContext.fetch(fetchRequest)
                    guard let taskModel = tasksModel.first else { return }
                    self.backgroundContext.delete(taskModel)
                    try self.saveContext()
                    promise(.success(()))
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
