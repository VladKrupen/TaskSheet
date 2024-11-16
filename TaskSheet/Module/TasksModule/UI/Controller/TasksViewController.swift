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
    
    private var tasks: [Task] = []
    
    var presenter: TasksPresenterProtocol?
    private let contentView = TasksView()
    
    //MARK: Life cycle
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        addTargets()
        presenter?.viewDidLoaded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
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
    
    //MARK: Create contextMenu
    private func createContextMenuConfiguration(task: Task) -> UIContextMenuConfiguration {
        let editAction = UIAction(title: LabelNames.edit, image: .edit) { _ in
            
        }
        let shareAction = UIAction(title: LabelNames.share, image: .export) { _ in
            
        }
        let deleteAction = UIAction(title: LabelNames.delete, image: .trash, attributes: .destructive) { _ in
            
        }
        let previewProvider: UIContextMenuContentPreviewProvider = {
            let previewController = PreviewForContextMenuController(task: task)
            return previewController
        }
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: previewProvider) { _ in
            return UIMenu(children: [editAction, shareAction, deleteAction])
        }
        return configuration
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
        presenter?.createTaskButtonWasPressed(action: .createTaskButton, task: nil)
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = Task(id: "adsdsd", title: "Почитать книгу", description: .init(), completed: true, date: Date())
        return createContextMenuConfiguration(task: task)
    }
}

//MARK: UITableViewDelegate
extension TasksViewController: UITableViewDelegate {
    
}
