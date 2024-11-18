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
    private var filteredTasks: [Task] = []
    private var searchText: String = .init()
    private var dispatchWorkItem: DispatchWorkItem?
    
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
        contentView.showSpinerForFetchTasks()
        presenter?.fetchTasks()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        contentView.endEditing(true)
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
    
    //MARK: Activity
    private func showActivity(task: Task) {
        let item: String = task.title + "\n" + task.description + "\n" + task.date.toCustomFormat()
        let activity = UIActivityViewController(activityItems: [item], applicationActivities: nil)
        DispatchQueue.main.async { [weak self] in
            self?.present(activity, animated: true)
        }
    }
    
    //MARK: Search
    private func searchTasks() {
        dispatchWorkItem?.cancel()
        contentView.showSpinerForSearch()
        dispatchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.sortTasks()
            DispatchQueue.main.async {
                self.contentView.taskTableView.reloadData()
                self.contentView.setTaskCounter(counter: self.filteredTasks.count)
                self.contentView.hideSpinerForSearch()
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            if self?.dispatchWorkItem?.isCancelled == false {
                self?.dispatchWorkItem?.perform()
            }
        }
    }
    
    //MARK: SortTasks
    private func sortTasks() {
        let searchString = searchText.lowercased()
        if !searchString.isEmpty {
            filteredTasks = tasks.filter { task in
                let title = task.title.lowercased()
                let description = task.description.lowercased()
                return title.contains(searchString) || description.contains(searchString)
            }
        } else {
            filteredTasks = tasks
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
        sortTasks()
        contentView.setTaskCounter(counter: filteredTasks.count)
        contentView.taskTableView.reloadData()
        contentView.hideSpinerForFetchTasks()
    }
    
    func updateStatusTask(task: Task) {
        guard let indexTask = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        guard let indexFilteredTask = filteredTasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[indexTask] = task
        filteredTasks[indexFilteredTask] = task
        contentView.taskTableView.reloadData()
    }
    
    func deleteTask(task: Task) {
        guard let indexTask = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        guard let indexFilteredTask = filteredTasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks.remove(at: indexTask)
        filteredTasks.remove(at: indexFilteredTask)
        contentView.taskTableView.deleteRows(at: [IndexPath(row: indexFilteredTask, section: 0)], with: .top)
        contentView.setTaskCounter(counter: filteredTasks.count)
    }
}

//MARK: OBJC
extension TasksViewController {
    @objc private func imageInSearchFieldTapped() {
        guard let isEmptyText = contentView.searchField.isEmptyText else { return }
        if !isEmptyText {
            contentView.searchField.text = .init()
            contentView.searchField.isEmptyText = true
            searchText = .init()
            filteredTasks = tasks
            contentView.taskTableView.reloadData()
            contentView.setTaskCounter(counter: filteredTasks.count)
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
        searchText = text
        searchTasks()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentView.endEditing(true)
        return true
    }
}

//MARK: UITableViewDataSource
extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TaskTableViewCell.self),
                                                       for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.prepareForReuse()
        var task = filteredTasks[indexPath.row]
        cell.configureCell(task: task)
        cell.highlightText(searchText: searchText)
        cell.checkmarkImageViewAction = { [weak self] completed in
            task.completed = completed
            self?.presenter?.updateStatusTask(task: task)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return createContextMenuConfiguration(task: filteredTasks[indexPath.row])
    }
}
