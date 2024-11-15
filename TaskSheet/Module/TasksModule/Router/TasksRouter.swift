//
//  TasksRouter.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

protocol TasksRouterProtocol: AnyObject {
    func showTaskPageModule(action: TasksModuleActions, task: Task?)
}

final class TasksRouter: TasksRouterProtocol {
    weak var viewController: TasksViewController?
    
    func showTaskPageModule(action: TasksModuleActions, task: Task?) {
        let taskPageController = ModuleFactory.createTaskPageModule(action: action, task: task)
        viewController?.navigationController?.pushViewController(taskPageController, animated: true)
    }
}
