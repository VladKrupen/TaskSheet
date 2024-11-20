//
//  TasksInteractor.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation
import Combine

protocol TasksInteractorProtocol: AnyObject {
    func fetchTasks()
    func updateStatusTask(task: Task)
    func deleteTask(task: Task)
}

final class TasksInteractor {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private var fetchCancellable: AnyCancellable?
    private var updateCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?
    
    weak var presenterToView: TasksPresenterViewProtocol?
    private let networkManager: NetworkManagerProtocol
    private let userDefaultsManager: UserDefaultsManagerProtocol
    private let taskProvider: CoreDataTaskProvider
    private let updatingTask: CoreDataUpdatingTask
    private let deletingTask: CoreDataDeletingTask
    
    init(networkManager: NetworkManagerProtocol, userDefaultsManager: UserDefaultsManagerProtocol, taskProvider: CoreDataTaskProvider, updatingTask: CoreDataUpdatingTask, deletingTask: CoreDataDeletingTask) {
        self.networkManager = networkManager
        self.userDefaultsManager = userDefaultsManager
        self.taskProvider = taskProvider
        self.updatingTask = updatingTask
        self.deletingTask = deletingTask
    }
    
    private func fetchServerTasks() {
        networkManager.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                    self?.fetchLocalTasks()
                }
            } receiveValue: { [weak self] taskItems in
                self?.createLocalTasks(taskItems: taskItems)
            }
            .store(in: &cancellables)
    }
    
    private func createLocalTasks(taskItems: [TaskItem]) {
        taskProvider.createTasks(taskItems: taskItems)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.fetchLocalTasks()
                self?.userDefaultsManager.setHasReceivedTasksFromServer()
            }
            .store(in: &cancellables)
    }
    
    private func fetchLocalTasks() {
        fetchCancellable = taskProvider.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            } receiveValue: { [weak self] tasks in
                self?.presenterToView?.updateView(tasks: tasks)
            }
    }
}

//MARK: TasksInteractorProtocol
extension TasksInteractor: TasksInteractorProtocol {
    func fetchTasks() {
        userDefaultsManager.hasReceivedTasksFromServer() ? fetchLocalTasks() : fetchServerTasks()
    }
    
    func updateStatusTask(task: Task) {
        updateCancellable = updatingTask.updateTask(task: task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            }, receiveValue: { [weak self] _ in
                self?.presenterToView?.updateStatusTaskForView(task: task)
            })
    }
    
    func deleteTask(task: Task) {
        deleteCancellable = deletingTask.deleteTask(task: task)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            }, receiveValue: { [weak self] _ in
                self?.presenterToView?.deleteTaskForView(task: task)
            })
    }
}
