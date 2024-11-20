//
//  TaskPageInteractorTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 20.11.24.
//

import XCTest
import Combine
@testable import TaskSheet

final class TaskPageInteractorTests: XCTestCase {
    
    private var interactor: TaskPageInteractor!
    private var coreDataManagerMock: CoreDataManagerTaskPageMock!
    private var presenterToRouterMock: TaskPagePresenterMock!
    private var presenterToViewMock: TaskPagePresenterMock!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        coreDataManagerMock = CoreDataManagerTaskPageMock()
        presenterToRouterMock = TaskPagePresenterMock()
        presenterToViewMock = TaskPagePresenterMock()
        cancellables = .init()
    }

    override func tearDownWithError() throws {
        interactor = nil
        coreDataManagerMock = nil
        presenterToRouterMock = nil
        presenterToViewMock = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testEditTaskViewDidLoaded() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        interactor = TaskPageInteractor(action: .editTask,
                                        task: task,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        interactor.viewDidLoaded()
        
        XCTAssertTrue(presenterToViewMock.didUpdateViewForEditingTask, "Presenter should called")
        XCTAssertEqual(presenterToViewMock.receivedTask, task, "Presenter should receive a non-nil task")
    }
    
    func testCreateTask() {
        let title: String = "Test title"
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .createTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        interactor.createOrEditTask(title: title, description: description)
        createTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(coreDataManagerMock.didCreateTask, "CoreDataManager should called")
        XCTAssertTrue(presenterToRouterMock.didDismissTaskPageModule, "Presenter should called")
    }
    
    func testCreateTaskWithValidationError() {
        let title: String = ""
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .createTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        interactor.createOrEditTask(title: title, description: description)
        createTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(presenterToViewMock.didNotifyValidationFailure, "Presenter should called")
        XCTAssertFalse(coreDataManagerMock.didCreateTask, "CoreDataManager should not be called")
        XCTAssertEqual(presenterToViewMock.receivedMessage, message, "Presenter should receive a non-nil message")
    }
    
    func testCreateTaskWithError() {
        let title: String = "Test title"
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .createTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        coreDataManagerMock.errorToReturn = error
        interactor.createOrEditTask(title: title, description: description)
        createTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertTrue(coreDataManagerMock.didCreateTask, "CoreDataManager should called")
        XCTAssertEqual(presenterToViewMock.receivedError, error, "Presenter should receive a non-nil message")
    }
    
    func testEditTask() {
        let title: String = "Test title"
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .editTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        interactor.createOrEditTask(title: title, description: description)
        editTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(coreDataManagerMock.didUpdateTask, "CoreDataManager should called")
        XCTAssertTrue(presenterToRouterMock.didDismissTaskPageModule, "Presenter should called")
    }
    
    func testEditTaskWithValidationError() {
        let title: String = ""
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .editTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        interactor.createOrEditTask(title: title, description: description)
        editTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(presenterToViewMock.didNotifyValidationFailure, "Presenter should called")
        XCTAssertFalse(coreDataManagerMock.didUpdateTask, "CoreDataManager should not be called")
        XCTAssertEqual(presenterToViewMock.receivedMessage, message, "Presenter should receive a non-nil message")
    }
    
    func testEditTaskWithError() {
        let title: String = "Test title"
        let description: String = "Test description"
        let message: String = "Validation error"
        let error: TaskError = .somethingWentWrong
        interactor = TaskPageInteractor(action: .editTask,
                                        task: nil,
                                        creationTask: coreDataManagerMock,
                                        updatingTask: coreDataManagerMock)
        interactor.presenterToRouter = presenterToRouterMock
        interactor.presenterToView = presenterToViewMock
        
        coreDataManagerMock.errorToReturn = error
        interactor.createOrEditTask(title: title, description: description)
        editTask(title: title, description: description, message: message, error: error)
        
        XCTAssertTrue(presenterToViewMock.didDisplayError, "Presenter should called")
        XCTAssertTrue(coreDataManagerMock.didUpdateTask, "CoreDataManager should called")
        XCTAssertEqual(presenterToViewMock.receivedError, error, "Presenter should receive a non-nil message")
    }
    
    private func createTask(title: String, description: String, message: String, error: TaskError) {
        guard !title.isEmpty else {
            presenterToViewMock.notifyValidationFailure(message: message)
            return
        }
        let task = Task(id: "1", title: title, description: description, completed: false, date: Date())
        coreDataManagerMock.createTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.presenterToRouterMock.dismissTaskPageModule()
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func editTask(title: String, description: String, message: String, error: TaskError) {
        guard !title.isEmpty else {
            presenterToViewMock.notifyValidationFailure(message: message)
            return
        }
        let task = Task(id: "1", title: title, description: description, completed: false, date: Date())
        coreDataManagerMock.updateTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.presenterToRouterMock.dismissTaskPageModule()
                case .failure:
                    self?.presenterToViewMock.displayError(error: error)
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}

final class CoreDataManagerTaskPageMock: CoreDataCreationTask, CoreDataUpdatingTask {
    
    var didCreateTask: Bool = false
    var didUpdateTask: Bool = false
    var errorToReturn: TaskError?
    
    func createTask(task: Task) -> AnyPublisher<Void, TaskError> {
        didCreateTask = true
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

final class TaskPagePresenterMock {
    var receivedTask: Task?
    var didUpdateViewForEditingTask: Bool = false
    var didNotifyValidationFailure: Bool = false
    var receivedMessage: String?
    var didDismissTaskPageModule: Bool = false
    var didDisplayError: Bool = false
    var receivedError: TaskError?
}

extension TaskPagePresenterMock: TaskPagePresenterRouterProtocol {
    func dismissTaskPageModule() {
        didDismissTaskPageModule = true
    }
}

extension TaskPagePresenterMock: TaskPagePresenterViewProtocol {
    func updateViewForEditingTask(task: Task) {
        receivedTask = task
        didUpdateViewForEditingTask = true
    }
    
    func displayError(error: TaskError) {
        didDisplayError = true
        receivedError = error
    }
    
    func notifyValidationFailure(message: String) {
        didNotifyValidationFailure = true
        receivedMessage = message
    }
}

