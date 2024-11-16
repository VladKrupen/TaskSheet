//
//  TaskError.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation

enum TaskError: String, Error {
    case invalidURL = "Проблемы с подключением. Пожалуйста, повторите попытку позже"
    case invalidResponse = "Не удалось обработать запрос. Пожалуйста, повторите попытку позже"
    case somethingWentWrong = "Упс, что-то пошло не так. Пожалуйста, повторите попытку позже"
}
