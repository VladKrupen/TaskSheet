//
//  TaskPageViewController.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

protocol TaskPageViewProtocol: AnyObject {
    func updateViewForEditingTask(task: Task)
    func showError(error: TaskError)
    func showInvalidValidation(message: String)
}

final class TaskPageViewController: UIViewController {
    
    var presenter: TaskPagePresenterProtocol?
    private let contentView = TaskPageView()
    
    private let backButtonView = BackButtonView()
    
    //MARK: Life cycle
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        presenter?.viewDidLoaded()
    }
    
    //MARK: Get
    private func getTitle() -> String {
        guard let title = contentView.titleField.text else {
            return .init()
        }
        return title
    }
    
    private func getDescription() -> String {
        guard let description = contentView.descriptionTextView.text else {
            return .init()
        }
        guard description != Placeholders.description else {
            return .init()
        }
        return description
    }
    
    //MARK: Setup
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        backButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonViewTapped)))
    }
    
    //MARK: Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Alert.ok, style: .default) { [weak self] _ in
            self?.presenter?.dismissTaskPageModule()
        }
        alert.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
    
    private func showInvalidValidationAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Alert.ok, style: .default)
        let cancelAndExitAction = UIAlertAction(title: Alert.cancelAndExit, style: .destructive) { [weak self] _ in
            self?.presenter?.dismissTaskPageModule()
        }
        [okAction, cancelAndExitAction].forEach { alert.addAction($0) }
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
}

//MARK: TasksViewProtocol
extension TaskPageViewController: TaskPageViewProtocol {
    func updateViewForEditingTask(task: Task) {
        contentView.configureView(task: task)
    }
    
    func showError(error: TaskError) {
        showErrorAlert(message: error.rawValue)
    }
    
    func showInvalidValidation(message: String) {
        showInvalidValidationAlert(message: message)
    }
}

//MARK: OBJC
extension TaskPageViewController {
    @objc private func backButtonViewTapped() {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.backButtonView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { [weak self] _ in
            guard let self else { return }
            self.contentView.endEditing(true)
            self.presenter?.backButtonViewWasPressed(title: self.getTitle(), description: self.getDescription())
            UIView.animate(withDuration: 0.1) {
                self.backButtonView.transform = .identity
            }
        }
    }
}
