//
//  TasksPresenter.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

protocol TasksPresenterProtocol: AnyObject {
    func createTaskButtonWasPressed(action: TasksModuleActions, task: Task?)
    func viewDidLoaded()
    func displayError(error: TaskError)
    func updateView(tasks: [Task])
}

final class TasksPresenter: TasksPresenterProtocol {
    
    private weak var view: TasksViewProtocol?
    private let interactor: TasksInteractorProtocol
    private let router: TasksRouterProtocol
    
    init(view: TasksViewProtocol? = nil, interactor: TasksInteractorProtocol, router: TasksRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func createTaskButtonWasPressed(action: TasksModuleActions, task: Task?) {
        router.showTaskPageModule(action: action, task: task)
    }
    
    func viewDidLoaded() {
        interactor.fetchTasks()
    }
    
    func displayError(error: TaskError) {
        view?.showAlert(error: error)
    }
    
    func updateView(tasks: [Task]) {
        view?.updateView(tasks: tasks)
    }
}
