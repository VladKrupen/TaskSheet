//
//  TasksInteractorTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 20.11.24.
//

import XCTest
import Combine
@testable import TaskSheet

final class TasksInteractorTests: XCTestCase {
    
    private var interactor: TasksInteractor!
    private var coreDataManagerMock: CoreDataManagerTasksMock!
    private var userDefaultsManagerMock: UserDefaultsManagerMock!
    private var networkManagerMock: NetworkManagerMock!
    private var presenterToRouterMock: TasksPresenterMock!
    private var presenterToViewMock: TasksPresenterMock!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        super.setUp()
        coreDataManagerMock = CoreDataManagerTasksMock()
        userDefaultsManagerMock = UserDefaultsManagerMock()
        networkManagerMock = NetworkManagerMock()
        presenterToViewMock = TasksPresenterMock()
        interactor = TasksInteractor(networkManager: networkManagerMock,
                                     userDefaultsManager: userDefaultsManagerMock,
                                     taskProvider: coreDataManagerMock,
                                     updatingTask: coreDataManagerMock,
                                     deletingTask: coreDataManagerMock)
        interactor.presenterToView = presenterToViewMock
        cancellables = .init()
    }

    override func tearDownWithError() throws {
        interactor = nil
        coreDataManagerMock = nil
        userDefaultsManagerMock = nil
        networkManagerMock = nil
        presenterToViewMock = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testUpdateStatusTask() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        let error: TaskError = .somethingWentWrong
        
        interactor.updateStatusTask(task: task)
        updateStatusTask(task: task, error: error)
        
        XCTAssertTrue(presenterToViewMock.didUpdateStatusTaskForView, "Presenter should called")
        XCTAssertTrue(coreDataManagerMock.didUpdateTask, "CoreDataManager should called")
        XCTAssertEqual(presenterToViewMock.task, task, "Presenter should receive task")
    }
    
    func testUpdateStatusTaskWithError() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        let error: TaskError = .somethingWentWrong
        
        coreDataManagerMock.errorToReturn = error
        interactor.updateStatusTask(task: task)
        updateStatusTask(task: task, error: error)
        
        XCTAssertFalse(presenterToViewMock.didUpdateStatusTaskForView, "Presenter should not be called")
        XCTAssertTrue(coreDataManagerMock.didUpdateTask, "CoreDataManager should called")
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.error, error, "Presenter should receive error")
    }
    
    func testDeleteTask() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        let error: TaskError = .somethingWentWrong
        
        interactor.deleteTask(task: task)
        deleteTask(task: task, error: error)
        
        XCTAssertTrue(presenterToViewMock.didDeleteTaskForView, "Presenter should called")
        XCTAssertTrue(coreDataManagerMock.didDeleteTask, "CoreDataManager should called")
        XCTAssertEqual(presenterToViewMock.task, task, "Presenter should receive task")
    }
    
    func testDeleteTaskWithError() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        let error: TaskError = .somethingWentWrong
        
        coreDataManagerMock.errorToReturn = error
        interactor.deleteTask(task: task)
        deleteTask(task: task, error: error)
        
        XCTAssertFalse(presenterToViewMock.didDeleteTaskForView, "Presenter should not be called")
        XCTAssertTrue(coreDataManagerMock.didDeleteTask, "CoreDataManager should called")
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.error, error, "Presenter should receive error")
    }
    
    func testFetchServerTasks() {
        let error: TaskError = .somethingWentWrong
        
        fetchServerTasks(error: error)
        
        XCTAssertTrue(networkManagerMock.didFetchTasks, "NetworkManager should called")
        XCTAssertTrue(coreDataManagerMock.didCreateTasks, "CoreDataManager should called")
    }
    
    func testFetchServerTasksWithError() {
        let error: TaskError = .somethingWentWrong
        
        networkManagerMock.errorToReturn = error
        fetchServerTasks(error: error)
        
        XCTAssertTrue(networkManagerMock.didFetchTasks, "NetworkManager should called")
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.error, error, "Presenter should receive error")
        XCTAssertTrue(coreDataManagerMock.didFetchTasks, "CoreDataManager should called")
    }
    
    func testCreateLocalTask() {
        let error: TaskError = .somethingWentWrong
        createLocalTasks(taskItems: [], error: error)
        
        XCTAssertTrue(coreDataManagerMock.didCreateTasks, "CoreDataManager should called")
        XCTAssertTrue(coreDataManagerMock.didFetchTasks)
    }
    
    func testCreateLocalTaskWithError() {
        let error: TaskError = .somethingWentWrong
        
        coreDataManagerMock.errorToReturn = error
        createLocalTasks(taskItems: [], error: error)
        
        XCTAssertTrue(coreDataManagerMock.didCreateTasks, "CoreDataManager should called")
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.error, error, "Presenter should receive error")
    }
    
    func testFetchLocalTasks() {
        let error: TaskError = .somethingWentWrong
        
        fetchLocalTasks(error: error)
        
        XCTAssertTrue(coreDataManagerMock.didFetchTasks, "CoreDataManager should called")
        XCTAssertTrue(presenterToViewMock.didUpdateView, "CoreDataManager should called")
    }
    
    func testFetchLocalTasksWithError() {
        let error: TaskError = .somethingWentWrong
        
        coreDataManagerMock.errorToReturn = error
        fetchLocalTasks(error: error)
        
        XCTAssertTrue(coreDataManagerMock.didFetchTasks, "CoreDataManager should called")
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.error, error, "Presenter should receive error")
    }
    
    func testUserDefaultsManagerFirstBoot() {
        interactor.fetchTasks()
        XCTAssertTrue(userDefaultsManagerMock.didHasReceivedTasksFromServer, "UserDefaultsManager should called")
        XCTAssertTrue(networkManagerMock.didFetchTasks, "NetworkManager should called")
    }
    
    func testUserDefaultsManagerRepeatedBoot() {
        userDefaultsManagerMock.setHasReceivedTasksFromServer()
        interactor.fetchTasks()
        XCTAssertTrue(userDefaultsManagerMock.didHasReceivedTasksFromServer, "UserDefaultsManager should called")
        XCTAssertFalse(networkManagerMock.didFetchTasks, "NetworkManager should not be called")
    }
    
    private func updateStatusTask(task: Task, error: TaskError) {
        coreDataManagerMock.updateTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.presenterToViewMock.updateStatusTaskForView(task: task)
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func deleteTask(task: Task, error: TaskError) {
        coreDataManagerMock.deleteTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.presenterToViewMock.deleteTaskForView(task: task)
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func fetchServerTasks(error: TaskError) {
        networkManagerMock.fetchTasks()
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                    self?.fetchLocalTasks(error: error)
                }
            } receiveValue: { [weak self] taskItems in
                self?.createLocalTasks(taskItems: [], error: error)
            }
            .store(in: &cancellables)
    }
    
    private func createLocalTasks(taskItems: [TaskItem], error: TaskError) {
        coreDataManagerMock.createTasks(taskItems: taskItems)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { [weak self] _ in
                self?.fetchLocalTasks(error: error)
                self?.userDefaultsManagerMock.setHasReceivedTasksFromServer()
            }
            .store(in: &cancellables)
    }

    private func fetchLocalTasks(error: TaskError) {
        coreDataManagerMock.fetchTasks()
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { [weak self] tasks in
                self?.presenterToViewMock.updateView(tasks: tasks)
            }
            .store(in: &cancellables)
    }
}

final class TasksPresenterMock {
    var didDisplayError: Bool = false
    var didUpdateView: Bool = false
    var didUpdateStatusTaskForView: Bool = false
    var didDeleteTaskForView: Bool = false
    var action: TasksModuleActions?
    var task: Task?
    var error: TaskError?
    var tasks: [Task]?
}

extension TasksPresenterMock: TasksPresenterViewProtocol {
    func displayError(error: TaskError) {
        didDisplayError = true
        self.error = error
    }
    
    func updateView(tasks: [Task]) {
        didUpdateView = true
        self.tasks = tasks
    }
    
    func updateStatusTaskForView(task: Task) {
        didUpdateStatusTaskForView = true
        self.task = task
    }
    
    func deleteTaskForView(task: Task) {
        didDeleteTaskForView = true
        self.task = task
    }
}

final class CoreDataManagerTasksMock: CoreDataTaskProvider, CoreDataDeletingTask, CoreDataUpdatingTask {
    var didCreateTasks: Bool = false
    var didFetchTasks: Bool = false
    var didDeleteTask: Bool = false
    var didUpdateTask: Bool = false
    var errorToReturn: TaskError?
    var tasks: [Task] = [Task(id: "1", title: "Test", description: "Test", completed: true, date: Date())]
    
    func createTasks(taskItems: [TaskItem]) -> AnyPublisher<Void, TaskError> {
        didCreateTasks = true
        if let errorToReturn {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: TaskError.self)
                .eraseToAnyPublisher()
        }
    }
    
    func fetchTasks() -> AnyPublisher<[Task], TaskError> {
        didFetchTasks = true
        if let errorToReturn {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Just(tasks)
                .setFailureType(to: TaskError.self)
                .eraseToAnyPublisher()
        }
    }
    
    func deleteTask(task: Task) -> AnyPublisher<Void, TaskError> {
        didDeleteTask = true
        if let errorToReturn {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
    
    func updateTask(task: Task) -> AnyPublisher<Void, TaskError> {
        didUpdateTask = true
        if let errorToReturn {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}

final class NetworkManagerMock: NetworkManagerProtocol {
    var didFetchTasks: Bool = false
    var errorToReturn: TaskError?
    let taskItems: [TaskItem] = [TaskItem(id: 1, todo: "Test", completed: false, userId: 1)]
    func fetchTasks() -> AnyPublisher<[TaskItem], TaskError> {
        didFetchTasks = true
        if let errorToReturn {
            return Fail(error: errorToReturn).eraseToAnyPublisher()
        } else {
            return Just(taskItems)
                .setFailureType(to: TaskError.self)
                .eraseToAnyPublisher()
        }
    }
}

final class UserDefaultsManagerMock: UserDefaultsManagerProtocol {
    var didSetHasReceivedTasksFromServer: Bool = false
    var didHasReceivedTasksFromServer: Bool = false
    var completed: Bool = false
    
    func setHasReceivedTasksFromServer() {
        didSetHasReceivedTasksFromServer = true
        completed = true
    }
    
    func hasReceivedTasksFromServer() -> Bool {
        didHasReceivedTasksFromServer = true
        return completed
    }
}
