//
//  TasksPresenterTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 19.11.24.
//

import XCTest
@testable import TaskSheet

final class TasksPresenterTests: XCTestCase {

    private var presenter: TasksPresenter!
    private var viewMock: TasksViewMock!
    private var interactorMock: TasksInteractorMock!
    private var routerMock: TasksRouterMock!
    
    override func setUpWithError() throws {
        super.setUp()
        viewMock = TasksViewMock()
        interactorMock = TasksInteractorMock()
        routerMock = TasksRouterMock()
        presenter = TasksPresenter(view: viewMock, interactor: interactorMock, router: routerMock)
    }

    override func tearDownWithError() throws {
        presenter = nil
        viewMock = nil
        interactorMock = nil
        routerMock = nil
        super.tearDown()
    }
    
    func testDisplayError() {
        let error: TaskError = .somethingWentWrong
        presenter.displayError(error: error)
        XCTAssertTrue(viewMock.didShowError, "View should called")
        XCTAssertEqual(viewMock.receivedError, error, "View should display the correct error message")
    }
    
    func testUpdateView() {
        let tasks: [Task] = [
            Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date()),
            Task(id: "2", title: "Test title", description: "Test description", completed: true, date: Date()),
            Task(id: "3", title: "Test title", description: "Test description", completed: false, date: Date())
        ]
        presenter.updateView(tasks: tasks)
        XCTAssertTrue(viewMock.didUpdateView, "View should called")
        XCTAssertEqual(viewMock.receivedTasks, tasks, "View should receive a non-nil task")
    }
    
    func testUpdateStatusTaskForView() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        presenter.updateStatusTaskForView(task: task)
        XCTAssertTrue(viewMock.didUpdateStatusTask, "View should called")
        XCTAssertEqual(viewMock.receivedTask, task, "View should receive a non-nil task")
    }
    
    func testDeleteTaskForView() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        presenter.deleteTaskForView(task: task)
        XCTAssertTrue(viewMock.didDeleteTask, "View should called")
        XCTAssertEqual(viewMock.receivedTask, task, "View should receive a non-nil task")
    }
    
    func testFetchTasks() {
        presenter.fetchTasks()
        XCTAssertTrue(interactorMock.didFetchTasks, "Interactor should called")
    }
    
    func testUpdateStatusTask() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        presenter.updateStatusTask(task: task)
        XCTAssertTrue(interactorMock.didUpdateStatusTask, "Interactor should called")
        XCTAssertEqual(interactorMock.receivedTask, task, "Interactor should receive a non-nil task")
    }
    
    func testDeleteTask() {
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        presenter.deleteTask(task: task)
        XCTAssertTrue(interactorMock.didDeleteTask, "Interactor should called")
        XCTAssertEqual(interactorMock.receivedTask, task, "Interactor should receive a non-nil task")
    }
    
    func testHandleTaskAction() {
        let action: TasksModuleActions = .createTask
        let task = Task(id: "1", title: "Test title", description: "Test description", completed: false, date: Date())
        presenter.handleTaskAction(action: action, task: task)
        XCTAssertTrue(routerMock.didShowTaskPageModule, "Interactor should called")
        XCTAssertEqual(routerMock.receivedAction, action, "Interactor should receive a non-nil action")
        XCTAssertEqual(routerMock.receivedTask, task, "Interactor should receive a non-nil task")
    }
}

final class TasksViewMock: TasksViewProtocol {
    var didShowError: Bool = false
    var didUpdateView: Bool = false
    var didUpdateStatusTask: Bool = false
    var didDeleteTask: Bool = false
    var receivedError: TaskError?
    var receivedTasks: [Task]?
    var receivedTask: Task?
    
    func showError(error: TaskError) {
        didShowError = true
        receivedError = error
    }
    
    func updateView(tasks: [Task]) {
        didUpdateView = true
        receivedTasks = tasks
    }
    
    func updateStatusTask(task: Task) {
        didUpdateStatusTask = true
        receivedTask = task
    }
    
    func deleteTask(task: Task) {
        didDeleteTask = true
        receivedTask = task
    }
}

final class TasksInteractorMock: TasksInteractorProtocol {
    var didFetchTasks: Bool = false
    var didUpdateStatusTask: Bool = false
    var didDeleteTask: Bool = false
    var receivedTask: Task?
    
    func fetchTasks() {
        didFetchTasks = true
    }
    
    func updateStatusTask(task: Task) {
        didUpdateStatusTask = true
        receivedTask = task
    }
    
    func deleteTask(task: Task) {
        didDeleteTask = true
        receivedTask = task
    }
}

final class TasksRouterMock: TasksRouterProtocol {
    var didShowTaskPageModule: Bool = false
    var receivedAction: TasksModuleActions?
    var receivedTask: Task?
    
    func showTaskPageModule(action: TasksModuleActions, task: Task?) {
        didShowTaskPageModule = true
        receivedAction = action
        receivedTask = task
    }
}
