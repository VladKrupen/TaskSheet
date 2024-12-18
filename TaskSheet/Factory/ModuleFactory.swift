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
                                              taskProvider: coreDataManager,
                                              updatingTask: coreDataManager,
                                              deletingTask: coreDataManager)
        let tasksRouter = TasksRouter()
        let tasksPresenter = TasksPresenter(view: tasksViewController,
                                            interactor: tasksInteractor,
                                            router: tasksRouter)
        tasksViewController.presenterToRouter = tasksPresenter
        tasksViewController.presenterToInteractor = tasksPresenter
        tasksInteractor.presenterToView = tasksPresenter
        tasksRouter.viewController = tasksViewController
        return tasksViewController
    }
    
    static func createTaskPageModule(action: TasksModuleActions, task: Task?) -> TaskPageViewController {
        let taskPageViewController = TaskPageViewController()
        let taskPageInteractor = TaskPageInteractor(action: action,
                                                    task: task,
                                                    creationTask: coreDataManager,
                                                    updatingTask: coreDataManager)
        let taskPageRouter = TaskPageRouter()
        let taskPagePresenter = TaskPagePresenter(view: taskPageViewController,
                                                  interactor: taskPageInteractor,
                                                  router: taskPageRouter)
        taskPageViewController.presenterToInteractor = taskPagePresenter
        taskPageViewController.presenterToRouter = taskPagePresenter
        taskPageInteractor.presenterToRouter = taskPagePresenter
        taskPageInteractor.presenterToView = taskPagePresenter
        taskPageRouter.viewController = taskPageViewController
        return taskPageViewController
    }
}
