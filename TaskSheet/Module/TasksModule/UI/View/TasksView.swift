//
//  TasksView.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import UIKit

final class TasksView: UIView {
    
    private let titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor(hex: Colors.white)
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        $0.text = LabelNames.tasksForTitle
        return $0
    }(UILabel())
    
    let searchField: SearchField = {
        $0.isEmptyText = true
        $0.setPlaceholder(placeholder: Placeholders.search)
        return $0
    }(SearchField())
    
    private let footerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(hex: Colors.gray)
        return $0
    }(UIView())
    
    let createTaskButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setBackgroundImage(UIImage(systemName: SystemSymbols.squareAndPencil), for: .normal)
        $0.tintColor = UIColor(hex: Colors.yellow)
        return $0
    }(UIButton(type: .system))
    
    private let taskCounterLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor(hex: Colors.white)
        $0.numberOfLines = 1
        $0.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        return $0
    }(UILabel())
    
    let taskTableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(hex: Colors.black)
        $0.separatorStyle = .none
        $0.register(TaskTableViewCell.self, forCellReuseIdentifier: String(describing: TaskTableViewCell.self))
        return $0
    }(UITableView())
    
    private let spinerView: UIActivityIndicatorView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.style = .large
        $0.color = UIColor(hex: Colors.white)
        $0.hidesWhenStopped = true
        return $0
    }(UIActivityIndicatorView())
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: Colors.black)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configure
    func setTaskCounter(counter: Int) {
        taskCounterLabel.text = "\(counter) \(LabelNames.tasksForFooter)"
    }
    
    //MARK: Spiner
    func showSpinerForFetchTasks() {
        titleLabel.isHidden = true
        searchField.isHidden = true
        footerView.isHidden = true
        taskTableView.isHidden = true
        spinerView.startAnimating()
    }
    
    func hideSpinerForFetchTasks() {
        titleLabel.isHidden = false
        searchField.isHidden = false
        footerView.isHidden = false
        taskTableView.isHidden = false
        spinerView.stopAnimating()
    }
    
    func showSpinerForSearch() {
        taskTableView.isHidden = true
        spinerView.startAnimating()
    }
    
    func hideSpinerForSearch() {
        taskTableView.isHidden = false
        spinerView.stopAnimating()
    }
    
    
    //MARK: Layout
    private func layoutElements() {
        layoutTitleLabel()
        layoutSearchBar()
        layoutFooterView()
        layoutCreateTaskButton()
        layoutTaskCounterLabel()
        layoutTableView()
        layoutSpinerView()
    }
    
    private func layoutTitleLabel() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutSearchBar() {
        addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.heightAnchor.constraint(equalToConstant: 36),
            searchField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutFooterView() {
        addSubview(footerView)
        
        NSLayoutConstraint.activate([
            footerView.heightAnchor.constraint(equalToConstant: 83),
            footerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func layoutCreateTaskButton() {
        footerView.addSubview(createTaskButton)
        
        NSLayoutConstraint.activate([
            createTaskButton.widthAnchor.constraint(equalToConstant: 28),
            createTaskButton.heightAnchor.constraint(equalToConstant: 28),
            createTaskButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 15),
            createTaskButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
        ])
    }
    
    private func layoutTaskCounterLabel() {
        footerView.addSubview(taskCounterLabel)
        
        NSLayoutConstraint.activate([
            taskCounterLabel.centerYAnchor.constraint(equalTo: createTaskButton.centerYAnchor),
            taskCounterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            taskCounterLabel.trailingAnchor.constraint(lessThanOrEqualTo: createTaskButton.leadingAnchor, constant: -10),
            taskCounterLabel.leadingAnchor.constraint(greaterThanOrEqualTo: footerView.leadingAnchor, constant: 20)
        ])
    }
    
    private func layoutTableView() {
        addSubview(taskTableView)
        
        NSLayoutConstraint.activate([
            taskTableView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            taskTableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            taskTableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            taskTableView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func layoutSpinerView() {
        addSubview(spinerView)
        
        NSLayoutConstraint.activate([
            spinerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinerView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}
