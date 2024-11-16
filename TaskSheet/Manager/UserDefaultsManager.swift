//
//  UserDefaultsManager.swift
//  TaskSheet
//
//  Created by Vlad on 16.11.24.
//

import Foundation

protocol UserDefaultsManagerProtocol: AnyObject {
    func setHasReceivedTasksFromServer()
    func hasReceivedTasksFromServer() -> Bool
}

final class UserDefaultsManager: UserDefaultsManagerProtocol {
    private let userDefaults = UserDefaults.standard
    private let hasReceivedTasksFromServerKey: String = "hasReceivedTasksFromServer"
    
    func setHasReceivedTasksFromServer() {
        userDefaults.set(true, forKey: hasReceivedTasksFromServerKey)
    }
    
    func hasReceivedTasksFromServer() -> Bool {
        return userDefaults.bool(forKey: hasReceivedTasksFromServerKey)
    }
}
