//
//  TasksViewController.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import UIKit

protocol TasksViewProtocol: AnyObject {
    func showError(error: TaskError)
    func updateView(tasks: [Task])
    func updateStatusTask(task: Task)
    func deleteTask(task: Task)
}

final class TasksViewController: UIViewController, UITableViewDelegate {
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
        contentView.showSpiner()
        presenter?.fetchTasks()
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
    
    //MARK: Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Alert.ok, style: .default)
        alert.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true)
        }
    }
    
    private func showActivity(task: Task) {
        let item: String = task.title + "\n" + task.description + "\n" + task.date.toCustomFormat()
        let activity = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        DispatchQueue.main.async { [weak self] in
            self?.present(activity, animated: true)
        }
    }
    
    //MARK: Create contextMenu
    private func createContextMenuConfiguration(task: Task) -> UIContextMenuConfiguration {
        let editAction = UIAction(title: LabelNames.edit, image: .edit) { [weak self] _ in
            self?.presenter?.handleTaskAction(action: .editTask, task: task)
        }
        let shareAction = UIAction(title: LabelNames.share, image: .export) { [weak self] _ in
            self?.showActivity(task: task)
        }
        let deleteAction = UIAction(title: LabelNames.delete, image: .trash, attributes: .destructive) { [weak self] _ in
            self?.presenter?.deleteTask(task: task)
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
    func showError(error: TaskError) {
        showErrorAlert(message: error.rawValue)
    }
    
    func updateView(tasks: [Task]) {
        self.tasks = tasks
        contentView.setTaskCounter(counter: tasks.count)
        contentView.taskTableView.reloadData()
        contentView.hideSpiner()
    }
    
    func updateStatusTask(task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        contentView.taskTableView.reloadData()
    }
    
    func deleteTask(task: Task) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks.remove(at: index)
        tasks.sort { $0.date > $1.date }
        contentView.taskTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .top)
        contentView.setTaskCounter(counter: tasks.count)
    }
}

//MARK: OBJC
extension TasksViewController {
    @objc private func imageInSearchFieldTapped() {
        guard let isEmptyText = contentView.searchField.isEmptyText else { return }
        if !isEmptyText {
            contentView.searchField.text = .init()
            contentView.searchField.isEmptyText = true
        }
    }
    
    @objc private func contentViewTapped() {
        contentView.endEditing(true)
    }
    
    @objc private func createTaskButtonTapped() {
        presenter?.handleTaskAction(action: .createTask, task: nil)
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
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self),
                                                       for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        var task = tasks[indexPath.row]
        cell.configureCell(task: task)
        cell.checkmarkImageViewAction = { [weak self] completed in
            task.completed = completed
            self?.presenter?.updateStatusTask(task: task)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return createContextMenuConfiguration(task: tasks[indexPath.row])
    }
}
