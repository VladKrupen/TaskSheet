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
        contentView.setTaskCounter(counter: 100)
    }
    
    //MARK: Setup
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: Delegate
    private func setDelegate() {
        contentView.searchField.delegate = self
        contentView.taskTableView.dataSource = self
        contentView.taskTableView.delegate = self
    }
    
    //MARK: Target
    private func addTargets() {
        addTargetForImageInSearchField()
        addTargetForContentView()
        addTargetForCreateTaskButton()
    }
    
    private func addTargetForImageInSearchField() {
        contentView.searchField.addTapGesture(target: self, action: #selector(imageInSearchFieldTapped))
    }
    
    private func addTargetForContentView() {
        contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentViewTapped)))
    }
    
    private func addTargetForCreateTaskButton() {
        contentView.createTaskButton.addTarget(self, action: #selector(createTaskButtonTapped), for: .touchUpInside)
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
    
    @objc private func createTaskButtonTapped() {
        
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

//MARK: UITableViewDataSource
extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self),
                                                       for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let task = Task(id: "adsdsd", title: "Почитать книгу", description: "Составить список необходимых продуктов для ужина. Не забыть проверить, что уже есть в холодильнике.", completed: true, date: Date())
        cell.configureCell(task: task)
        cell.checkmarkImageViewAction = {
            cell.isCompleted?.toggle()
        }
        return cell
    }
}

//MARK: UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
}
