//
//  TaskPagePresenter.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPagePresenterProtocol: AnyObject {
    //MARK: Router
    func dismissTaskPageModule()
    //MARK: Interactor
    func viewDidLoaded()
    func backButtonViewWasPressed(title: String, description: String)
    //MARK: View
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

//MARK: TaskPagePresenterProtocol
extension TaskPagePresenter: TaskPagePresenterProtocol {
    //MARK: Router
    func dismissTaskPageModule() {
        router.dismissTaskPageModule()
    }
    
    //MARK: Interactor
    func viewDidLoaded() {
        interactor.viewDidLoaded()
    }
    
    func backButtonViewWasPressed(title: String, description: String) {
        interactor.createOrEditTask(title: title, description: description)
    }
    
    //MARK: View
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
