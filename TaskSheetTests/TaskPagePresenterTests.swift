//
//  TaskPagePresenterTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 19.11.24.
//

import XCTest
@testable import TaskSheet

final class TaskPagePresenterTests: XCTestCase {
    
    private var presenter: TaskPagePresenter!
    private var viewMock: TaskPageViewMock!
    private var interactorMock: TaskPageInteractorMock!
    private var routerMock: TaskPageRouterMock!

    override func setUpWithError() throws {
        super.setUp()
        viewMock = TaskPageViewMock()
        interactorMock = TaskPageInteractorMock()
        routerMock = TaskPageRouterMock()
        presenter = TaskPagePresenter(view: viewMock,
                                      interactor: interactorMock,
                                      router: routerMock)
    }

    override func tearDownWithError() throws {
        presenter = nil
        viewMock = nil
        interactorMock = nil
        routerMock = nil
        super.tearDown()
    }
    
    func testUpdateViewForEditingTask() {
        let task = Task(id: UUID().uuidString,
                        title: "Test title",
                        description: "Test description",
                        completed: false,
                        date: Date())
        presenter.updateViewForEditingTask(task: task)
        XCTAssertTrue(viewMock.didUpdateViewForEditingTask, "View should be updated")
        XCTAssertNotNil(viewMock.receivedTask, "View should receive a non-nil task")
    }
    
    
    func testDisplayError() {
        let error: TaskError = .somethingWentWrong
        presenter.displayError(error: error)
        XCTAssertTrue(viewMock.didShowError, "View should display error")
        XCTAssertEqual(viewMock.displayedError, error, "View should display the correct error message")
    }
    
    func testNotifyValidationFailure() {
        let message: String = "Test message"
        presenter.notifyValidationFailure(message: message)
        XCTAssertTrue(viewMock.didShowInvalidValidation, "View should display message")
        XCTAssertEqual(viewMock.displayedMessage, message, "View should display the correct message")
    }
    
    func testViewDidLoaded() {
        presenter.viewDidLoaded()
        XCTAssertTrue(interactorMock.didViewDidLoaded, "Interactor should called")
    }
    
    func testBackButtonViewWasPressed() {
        let title: String = "Test title"
        let description: String = "Test description"
        presenter.backButtonViewWasPressed(title: title, description: description)
        XCTAssertTrue(interactorMock.didCreateOrEditTask, "Interactor should called")
        XCTAssertEqual(interactorMock.receivedTitle, title, "Interactor should receive title")
        XCTAssertEqual(interactorMock.receivedDescription, description, "Interactor should receive description")
    }
    
    func test() {
        presenter.dismissTaskPageModule()
        XCTAssertTrue(routerMock.didDismissTaskPageModule, "Router should called")
    }
}

final class TaskPageViewMock: TaskPageViewProtocol {
    var didUpdateViewForEditingTask: Bool = false
    var didShowError: Bool = false
    var didShowInvalidValidation: Bool = false
    var receivedTask: Task?
    var displayedError: TaskError?
    var displayedMessage: String?
    
    func updateViewForEditingTask(task: Task) {
        didUpdateViewForEditingTask = true
        receivedTask = task
    }
    
    func showError(error: TaskError) {
        didShowError = true
        displayedError = error
    }
    
    func showInvalidValidation(message: String) {
        didShowInvalidValidation = true
        displayedMessage = message
    }
}

final class TaskPageInteractorMock: TaskPageInteractorProtocol {
    var didViewDidLoaded: Bool = false
    var didCreateOrEditTask: Bool = false
    var receivedTitle: String?
    var receivedDescription: String?
    
    func viewDidLoaded() {
        didViewDidLoaded = true
    }
    
    func createOrEditTask(title: String, description: String) {
        didCreateOrEditTask = true
        receivedTitle = title
        receivedDescription = description
    }
}

final class TaskPageRouterMock: TaskPageRouterProtocol {
    var didDismissTaskPageModule: Bool = false
    
    func dismissTaskPageModule() {
        didDismissTaskPageModule = true
    }
}
