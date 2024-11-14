//
//  TasksInteractor.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import Foundation

protocol TasksInteractorProtocol: AnyObject {
    
}

final class TasksInteractor: TasksInteractorProtocol {
    
    weak var presenter: TasksPresenterProtocol?
}
