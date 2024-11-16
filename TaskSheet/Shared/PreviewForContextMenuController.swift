//
//  PreviewForContextMenuController.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

final class PreviewForContextMenuController: UIViewController {
    
    private let task: Task
    
    //MARK: UI
    private let contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(hex: Colors.gray)
        $0.layer.cornerRadius = 12
        return $0
    }(UIView())
    
    private let titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 20, weight: .regular)
        $0.textColor = UIColor(hex: Colors.white)
        return $0
    }(UILabel())
    
    private let descriptionLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 40).isActive = true
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(hex: Colors.white)
        return $0
    }(UILabel())
    
    private let dateLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.heightAnchor.constraint(equalToConstant: 20).isActive = true
        $0.numberOfLines = 1
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(hex: Colors.white, alpha: 0.5)
        return $0
    }(UILabel())
    
    private let vStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 8
        return $0
    }(UIStackView())
    
    //MARK: Init
    init(task: Task) {
        self.task = task
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutElements()
        configuration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preferredContentSize = contentView.frame.size
    }
    
    //MARK: Configuration
    private func configuration() {
        titleLabel.text = task.title
        setupDescriptionLabel(description: task.description)
        formatAndSetDateLabel(date: task.date)
    }
    
    //MARK: Setup
    private func setupDescriptionLabel(description: String) {
        guard !description.isEmpty else {
            descriptionLabel.isHidden = true
            return
        }
        descriptionLabel.isHidden = false
        descriptionLabel.text = description
    }
    
    private func formatAndSetDateLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    //MARK: Layout
    private func layoutElements() {
        layoutContentView()
        layoutVStackView()
    }
    
    private func layoutContentView() {
        view.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
    }
    
    private func layoutVStackView() {
        [titleLabel, descriptionLabel, dateLabel].forEach { vStackView.addArrangedSubview($0) }
        contentView.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            vStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
    }
}
