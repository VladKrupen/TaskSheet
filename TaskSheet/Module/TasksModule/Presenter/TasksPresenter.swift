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
}
