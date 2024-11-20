//
//  TaskPageInteractor.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation
import Combine

protocol TaskPageInteractorProtocol: AnyObject {
    func viewDidLoaded()
    func createOrEditTask(title: String, description: String)
}

final class TaskPageInteractor {
    private var cancellables: Set<AnyCancellable> = .init()
    
    weak var presenterToRouter: TaskPagePresenterRouterProtocol?
    weak var presenterToView: TaskPagePresenterViewProtocol?
    private let action: TasksModuleActions
    private var task: Task?
    private let creationTask: CoreDataCreationTask
    private let updatingTask: CoreDataUpdatingTask
    
    init(action: TasksModuleActions, task: Task?, creationTask: CoreDataCreationTask, updatingTask: CoreDataUpdatingTask) {
        self.action = action
        self.task = task
        self.creationTask = creationTask
        self.updatingTask = updatingTask
    }
    
    private func createTask(title: String, description: String) {
        guard !title.isEmpty else {
            presenterToView?.notifyValidationFailure(message: Alert.emptyTitleMessage)
            return
        }
        let newTask = Task(id: UUID().uuidString,
                           title: title,
                           description: description,
                           completed: false,
                           date: Date())
        creationTask.createTask(task: newTask)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.presenterToRouter?.dismissTaskPageModule()
            }
            .store(in: &cancellables)
    }
    
    private func editTask(title: String, description: String) {
        guard !title.isEmpty else {
            presenterToView?.notifyValidationFailure(message: Alert.emptyTitleMessage)
            return
        }
        guard let task else {
            presenterToView?.displayError(error: .somethingWentWrong)
            return
        }
        let updatedTask = Task(id: task.id,
                               title: title,
                               description: description,
                               completed: task.completed,
                               date: task.date)
        updatingTask.updateTask(task: updatedTask)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    self?.presenterToView?.displayError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.presenterToRouter?.dismissTaskPageModule()
            }
            .store(in: &cancellables)
    }
}

//MARK: TaskPageInteractorProtocol
extension TaskPageInteractor: TaskPageInteractorProtocol {
    func viewDidLoaded() {
        switch action {
        case .createTask:
            return
        case .editTask:
            guard let task else { return }
            presenterToView?.updateViewForEditingTask(task: task)
        }
    }
    
    func createOrEditTask(title: String, description: String) {
        switch action {
        case .createTask:
            createTask(title: title, description: description)
        case .editTask:
            editTask(title: title, description: description)
        }
    }
}
