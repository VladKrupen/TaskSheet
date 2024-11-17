//
//  TaskPageRouter.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import Foundation

protocol TaskPageRouterProtocol: AnyObject {
    func dismissTaskPageModule()
}

final class TaskPageRouter: TaskPageRouterProtocol {
    weak var viewController: TaskPageViewController?
    
    func dismissTaskPageModule() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
