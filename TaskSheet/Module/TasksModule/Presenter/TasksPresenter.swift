//
//  TasksPresenter.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

protocol TasksPresenterProtocol: AnyObject {
    //MARK: Router
    func handleTaskAction(action: TasksModuleActions, task: Task?)
    //MARK: Interactor
    func fetchTasks()
    func updateStatusTask(task: Task)
    func deleteTask(task: Task)
    //MARK: View
    func displayError(error: TaskError)
    func updateView(tasks: [Task])
    func updateStatusTaskForView(task: Task)
    func deleteTaskForView(task: Task)
}

final class TasksPresenter {
    
    private weak var view: TasksViewProtocol?
    private let interactor: TasksInteractorProtocol
    private let router: TasksRouterProtocol
    
    init(view: TasksViewProtocol? = nil, interactor: TasksInteractorProtocol, router: TasksRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension TasksPresenter: TasksPresenterProtocol {
    //MARK: Router
    func handleTaskAction(action: TasksModuleActions, task: Task?) {
        router.showTaskPageModule(action: action, task: task)
    }
    
    //MARK: Interactor
    func fetchTasks() {
        interactor.fetchTasks()
    }
    
    func updateStatusTask(task: Task) {
        interactor.updateStatusTask(task: task)
    }
    
    func deleteTask(task: Task) {
        interactor.deleteTask(task: task)
    }
    
    //MARK: View
    func displayError(error: TaskError) {
        view?.showError(error: error)
    }
    
    func updateView(tasks: [Task]) {
        view?.updateView(tasks: tasks)
    }
    
    func updateStatusTaskForView(task: Task) {
        view?.updateStatusTask(task: task)
    }
    
    func deleteTaskForView(task: Task) {
        view?.deleteTask(task: task)
    }
}
