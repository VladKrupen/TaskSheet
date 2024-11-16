//
//  ModuleFactory.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

final class ModuleFactory {
    static let networkManager = NetworkManager()
    static let userDefaultsManager = UserDefaultsManager()
    static let coreDataManager = CoreDataManager()
    
    static func createTasksModule() -> TasksViewController {
        let tasksViewController = TasksViewController()
        let tasksInteractor = TasksInteractor(networkManager: networkManager,
                                              userDefaultsManager: userDefaultsManager,
                                              coreDataTasks: coreDataManager)
        let tasksRouter = TasksRouter()
        let tasksPresenter = TasksPresenter(view: tasksViewController,
                                            interactor: tasksInteractor,
                                            router: tasksRouter)
        tasksViewController.presenter = tasksPresenter
        tasksInteractor.presenter = tasksPresenter
        tasksRouter.viewController = tasksViewController
        return tasksViewController
    }
    
    static func createTaskPageModule(action: TasksModuleActions, task: Task?) -> TaskPageViewController {
        let taskPageViewController = TaskPageViewController()
        let taskPageInteractor = TaskPageInteractor(action: action,
                                                    task: task)
        let taskPageRouter = TaskPageRouter()
        let taskPagePresenter = TaskPagePresenter(view: taskPageViewController,
                                                  interactor: taskPageInteractor,
                                                  router: taskPageRouter)
        taskPageViewController.presenter = taskPagePresenter
        taskPageInteractor.presenter = taskPagePresenter
        taskPageRouter.viewController = taskPageViewController
        return taskPageViewController
    }
}
