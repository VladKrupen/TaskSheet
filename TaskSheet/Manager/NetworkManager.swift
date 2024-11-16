//
//  NetworkManager.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation
import Combine

protocol NetworkManagerProtocol: AnyObject {
    func fetchTasks() -> AnyPublisher<[TaskItem], TaskError>
}

final class NetworkManager: NetworkManagerProtocol {
    private let url = URL(string: "https://dummyjson.com/todos")
    
    func fetchTasks() -> AnyPublisher<[TaskItem], TaskError> {
        return Future<[TaskItem], TaskError> { [weak self] promise in
            guard let url = self?.url else {
                promise(.failure(.invalidURL))
                return
            }
            let urlRequest = URLRequest(url: url)
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                guard error == nil,
                      let data else {
                    promise(.failure(.invalidResponse))
                    return
                }
                do {
                    let tasksResponse = try JSONDecoder().decode(TaskResponse.self, from: data)
                    promise(.success(tasksResponse.todos))
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
}
