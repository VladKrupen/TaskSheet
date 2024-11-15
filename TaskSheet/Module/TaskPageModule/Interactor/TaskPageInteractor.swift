//
//  TaskPageInteractor.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPageInteractorProtocol: AnyObject {
    
}

final class TaskPageInteractor: TaskPageInteractorProtocol {
    weak var presenter: TaskPagePresenterProtocol?
    private let action: TasksModuleActions
    private var task: Task?
    
    init(action: TasksModuleActions, task: Task?) {
        self.action = action
        self.task = task
    }
}
