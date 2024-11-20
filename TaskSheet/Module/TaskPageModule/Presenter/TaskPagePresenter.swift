//
//  TaskPagePresenter.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPagePresenterRouterProtocol: AnyObject {
    func dismissTaskPageModule()
}

protocol TaskPagePresenterInteractorProtocol: AnyObject {
    func viewDidLoaded()
    func backButtonViewWasPressed(title: String, description: String)
}

protocol TaskPagePresenterViewProtocol: AnyObject {
    func updateViewForEditingTask(task: Task)
    func displayError(error: TaskError)
    func notifyValidationFailure(message: String)
}

final class TaskPagePresenter {
    private weak var view: TaskPageViewProtocol?
    private let interactor: TaskPageInteractorProtocol
    private let router: TaskPageRouterProtocol
    
    init(view: TaskPageViewProtocol? = nil, interactor: TaskPageInteractorProtocol, router: TaskPageRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

//MARK: TaskPagePresenterRouterProtocol
extension TaskPagePresenter: TaskPagePresenterRouterProtocol {
    func dismissTaskPageModule() {
        router.dismissTaskPageModule()
    }
}

//MARK: TaskPagePresenterInteractorProtocol
extension TaskPagePresenter: TaskPagePresenterInteractorProtocol {
    func viewDidLoaded() {
        interactor.viewDidLoaded()
    }
    
    func backButtonViewWasPressed(title: String, description: String) {
        interactor.createOrEditTask(title: title, description: description)
    }
}

//MARK: TaskPagePresenterViewProtocol
extension TaskPagePresenter: TaskPagePresenterViewProtocol {
    func updateViewForEditingTask(task: Task) {
        view?.updateViewForEditingTask(task: task)
    }
    
    func displayError(error: TaskError) {
        view?.showError(error: error)
    }
    
    func notifyValidationFailure(message: String) {
        view?.showInvalidValidation(message: message)
    }
}
