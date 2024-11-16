//
//  SceneDelegate.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: ModuleFactory.createTasksModule())
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = .light
        self.window = window
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        let coreDataSaving: CoreDataSaving = CoreDataManager()
        do {
            try coreDataSaving.saveContext()
        } catch {
            print(error.localizedDescription)
        }
    }
}

