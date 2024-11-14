//
//  TasksViewController.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import UIKit

protocol TasksViewProtocol: AnyObject {
    
}

final class TasksViewController: UIViewController {
    
    var presenter: TasksPresenterProtocol?
    private let contentView = TasksView()
    
    //MARK: Life cycle
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setDelegate()
        addTargets()
    }
    
    //MARK: Setup
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Delegate
    private func setDelegate() {
        contentView.searchField.delegate = self
    }
    
    //MARK: Target
    private func addTargets() {
        addTargetForImageInSearchField()
        addTargetForContentView()
    }
    
    private func addTargetForImageInSearchField() {
        contentView.searchField.addTapGesture(target: self, action: #selector(imageInSearchFieldTapped))
    }
    
    private func addTargetForContentView() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewTapped)))
    }
}

//MARK: TasksViewProtocol
extension TasksViewController: TasksViewProtocol {
    
}

//MARK: OBJC
extension TasksViewController {
    @objc private func imageInSearchFieldTapped() {
        guard let isEmptyText = contentView.searchField.isEmptyText else { return }
        if !isEmptyText {
            contentView.searchField.text = .init()
        }
    }
    
    @objc private func contentViewTapped() {
        contentView.endEditing(true)
    }
}

//MARK: UITextFieldDelegate
extension TasksViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        contentView.searchField.isEmptyText = text.isEmpty
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.endEditing(true)
        return true
    }
}
