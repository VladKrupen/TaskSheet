//
//  CoreDataManagerTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 19.11.24.
//

import XCTest
import Combine
import CoreData
@testable import TaskSheet

final class CoreDataManagerTests: XCTestCase {
    
    private var persistentContainer: NSPersistentContainer!
    private var coreDataManager: CoreDataManager!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        persistentContainer = NSPersistentContainer(name: "TaskSheet")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                XCTFail("Failed to load in-memory store: \(error.localizedDescription)")
            }
        }
        
        coreDataManager = CoreDataManager(persistentContainer: persistentContainer)
        cancellables = .init()
    }
    
    override func tearDownWithError() throws {
        persistentContainer = nil
        coreDataManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testSaveContext() {
        let expectation = expectation(description: "Сontext saved successfully")
        XCTAssertNoThrow(try coreDataManager.saveContext(), "Failed to save context")
        expectation.fulfill()
        wait(for: [expectation], timeout: 5)
    }
    
    func testCreateTaskItemsAndFetchTasks() {
        let expectation = expectation(description: "Tasks received successfully")
        let taskItems: [TaskItem] = [
            TaskItem(id: 1, todo: "Test title1", completed: true, userId: 1),
            TaskItem(id: 2, todo: "Test title2", completed: false, userId: 2),
            TaskItem(id: 3, todo: "Test title3", completed: true, userId: 3)
        ]
        coreDataManager.createTasks(taskItems: taskItems)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchTasks(count: taskItems.count, expectation: expectation)
                case .failure(let error):
                    XCTFail("Creating tasks failed with error: \(error.rawValue)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 5)
    }
    
    func testCreateTask() {
        let expectation = expectation(description: "Task created successfully")
        let task = Task(id: UUID().uuidString, title: "Test title", description: "Test description", completed: false, date: Date())
        coreDataManager.createTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchTasks(count: 1, expectation: expectation)
                case .failure(let error):
                    XCTFail("Creating task failed with error: \(error.rawValue)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
       
        wait(for: [expectation], timeout: 5)
    }
    
    func testDeleteTask() {
        let expectation = expectation(description: "Task deleted successfully")
        let task = Task(id: UUID().uuidString, title: "Test title", description: "Test description", completed: false, date: Date())
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        coreDataManager.createTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchTasks(count: 1, dispatchGroup: dispatchGroup)
                case .failure(let error):
                    XCTFail("Creating task failed with error: \(error.rawValue)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self else { return }
            coreDataManager.deleteTask(task: task)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.fetchTasks(count: 0, expectation: expectation)
                    case .failure(let error):
                        XCTFail("Deleting task failed with error: \(error.rawValue)")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
        wait(for: [expectation], timeout: 5)
    }
    
    func testUpdateTask() {
        let expectation = expectation(description: "Task deleted successfully")
        var task = Task(id: UUID().uuidString, title: "Test title", description: "Test description", completed: false, date: Date())
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        coreDataManager.createTask(task: task)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.fetchTasks(count: 1, dispatchGroup: dispatchGroup)
                case .failure(let error):
                    XCTFail("Creating task failed with error: \(error.rawValue)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
        
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            guard let self else { return }
            task.title = "Updated title"
            task.description = "Updated description"
            task.completed = true
            coreDataManager.updateTask(task: task)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.fetchTasks(count: 1, expectation: expectation, task: task)
                    case .failure(let error):
                        XCTFail("Updating task failed with error: \(error.rawValue)")
                    }
                } receiveValue: { _ in }
                .store(in: &cancellables)
        }
        wait(for: [expectation], timeout: 5)
    }
    
    private func fetchTasks(count: Int, expectation: XCTestExpectation? = nil, dispatchGroup: DispatchGroup? = nil, task: Task? = nil) {
        coreDataManager.fetchTasks()
            .sink { completion in
                switch completion {
                case .finished:
                    if let dispatchGroup {
                        dispatchGroup.leave()
                    }
                    break
                case .failure(let error):
                    XCTFail("Receiving tasks failed with error: \(error.rawValue)")
                }
            } receiveValue: { tasks in
                XCTAssertEqual(count, tasks.count, "Tasks count should be equal")
                if let task {
                    XCTAssertEqual(tasks.first?.title, task.title, "Title should be equal")
                    XCTAssertEqual(tasks.first?.description, task.description, "Description should be equal")
                    XCTAssertEqual(tasks.first?.completed, task.completed, "Completed should be equal")
                }
                if let expectation {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
    }
}
