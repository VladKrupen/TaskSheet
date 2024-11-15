//
//  TaskPagePresenter.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPagePresenterProtocol: AnyObject {
    
}

final class TaskPagePresenter: TaskPagePresenterProtocol {
    private weak var view: TaskPageViewProtocol?
    private let interactor: TaskPageInteractorProtocol
    private let router: TaskPageRouterProtocol
    
    init(view: TaskPageViewProtocol? = nil, interactor: TaskPageInteractorProtocol, router: TaskPageRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}
