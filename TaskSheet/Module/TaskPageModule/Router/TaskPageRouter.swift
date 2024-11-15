//
//  TaskPageRouter.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPageRouterProtocol: AnyObject {
    
}

final class TaskPageRouter: TaskPageRouterProtocol {
    weak var viewController: TaskPageViewController?
}
