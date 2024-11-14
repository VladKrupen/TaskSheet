//
//  ModuleFactory.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

final class ModuleFactory {
    static func createTasksModule() -> TasksViewController {
        let tasksViewController = TasksViewController()
        let tasksInteractor = TasksInteractor()
        let tasksRouter = TasksRouter()
        let tasksPresenter = TasksPresenter(view: tasksViewController,
                                            interactor: tasksInteractor,
                                            router: tasksRouter)
        tasksViewController.presenter = tasksPresenter
        tasksInteractor.presenter = tasksPresenter
        tasksRouter.tasksViewController = tasksViewController
        return tasksViewController
    }
}
