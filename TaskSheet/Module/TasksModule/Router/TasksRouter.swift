//
//  TasksRouter.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

protocol TasksRouterProtocol: AnyObject {
    
}

final class TasksRouter: TasksRouterProtocol {
    weak var tasksViewController: TasksViewController?
}
