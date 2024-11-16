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

final class TasksInteractor: TasksInteractorProtocol {
    
    private var cancellable: AnyCancellable?
    
    weak var presenter: TasksPresenterProtocol?
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
    
    func fetchTasks() {
        cancellable = networkManager.fetchTasks()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { tasks in
                print(tasks.count)
            }
    }
}
