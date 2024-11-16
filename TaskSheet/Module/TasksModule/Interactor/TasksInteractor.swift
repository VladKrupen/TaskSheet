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
}

final class TasksInteractor {
    
    private var cancellables: Set<AnyCancellable> = .init()
    private var fetchCancellable: AnyCancellable?
    
    weak var presenter: TasksPresenterProtocol?
    private let networkManager: NetworkManagerProtocol
    private let userDefaultsManager: UserDefaultsManagerProtocol
    private let coreDataTasks: CoreDataTasks
    
    init(networkManager: NetworkManagerProtocol, userDefaultsManager: UserDefaultsManagerProtocol, coreDataTasks: CoreDataTasks) {
        self.networkManager = networkManager
        self.userDefaultsManager = userDefaultsManager
        self.coreDataTasks = coreDataTasks
    }
    
    private func fetchServerTasks() {
        networkManager.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenter?.displayError(error: error)
                    self?.fetchLocalTasks()
                }
            } receiveValue: { [weak self] taskItems in
                self?.createLocalTasks(taskItems: taskItems)
            }
            .store(in: &cancellables)
    }
    
    private func createLocalTasks(taskItems: [TaskItem]) {
        coreDataTasks.createTasks(taskItems: taskItems)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenter?.displayError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.fetchLocalTasks()
                self?.userDefaultsManager.setHasReceivedTasksFromServer()
            }
            .store(in: &cancellables)
    }
    
    private func fetchLocalTasks() {
        fetchCancellable = coreDataTasks.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenter?.displayError(error: error)
                }
            } receiveValue: { [weak self] tasks in
                self?.presenter?.updateView(tasks: tasks)
            }
    }
}

//MARK: TasksInteractorProtocol
extension TasksInteractor: TasksInteractorProtocol {
    func fetchTasks() {
        userDefaultsManager.hasReceivedTasksFromServer() ? fetchLocalTasks() : fetchServerTasks()
    }
}
