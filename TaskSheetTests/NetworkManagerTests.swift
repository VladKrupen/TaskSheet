//
//  NetworkManagerTests.swift
//  TaskSheetTests
//
//  Created by Vlad on 19.11.24.
//

import XCTest
import Combine
@testable import TaskSheet

final class NetworkManagerTests: XCTestCase {
    
    private var networkManager: NetworkManagerProtocol!
    private var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        super.setUp()
        networkManager = NetworkManager()
        cancellables = .init()
    }

    override func tearDownWithError() throws {
        networkManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testFetchTasksSuccess() {
        let expectation = expectation(description: "Tasks fetched successfully")
        networkManager.fetchTasks()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    XCTFail("Fetch tasks failed with error: \(error.rawValue)")
                }
            } receiveValue: { taskItems in
                XCTAssertFalse(taskItems.isEmpty, "Server tasks should not be empty")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 10)
    }
}

