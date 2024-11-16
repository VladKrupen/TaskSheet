//
//  TaskResponse.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation

struct TaskItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

struct TaskResponse: Decodable {
    let todos: [TaskItem]
    let total: Int
    let skip: Int
    let limit: Int
}
