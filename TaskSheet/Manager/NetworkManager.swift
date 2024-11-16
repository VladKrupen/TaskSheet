//
//  NetworkManager.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation
import Combine

protocol NetworkManagerProtocol: AnyObject {
    func fetchTasks() -> AnyPublisher<[Task], TaskError>
}

final class NetworkManager: NetworkManagerProtocol {
    private let url = URL(string: "https://dummyjson.com/todos")
    
    func fetchTasks() -> AnyPublisher<[Task], TaskError> {
        return Future<[Task], TaskError> { [weak self] promise in
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
                    var tasks: [Task] = []
                    let dispatchGroup = DispatchGroup()
                    for item in tasksResponse.todos {
                        dispatchGroup.enter()
                        let task = Task(id: String(item.id),
                                        title: item.todo,
                                        description: .init(),
                                        completed: item.completed,
                                        date: Date())
                        tasks.append(task)
                        dispatchGroup.leave()
                    }
                    dispatchGroup.notify(queue: .global()) {
                        promise(.success(tasks))
                    }
                } catch {
                    promise(.failure(.somethingWentWrong))
                }
            }
            .resume()
        }
        .eraseToAnyPublisher()
    }
}
