//
//  TaskTableViewCell.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

final class TaskTableViewCell: UITableViewCell {
    
    var checkmarkImageViewAction: (() -> Void)?
    
    var isCompleted: Bool? {
        willSet {
            guard let newValue else { return }
            updateForCompletionStatus(isCompleted: newValue)
        }
    }
    
    //MARK: UI
    private let checkmarkImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView())
    
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
    
    private let separatorForCell: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(hex: Colors.white, alpha: 0.2)
        return $0
    }(UIView())
    
    private let separatorForTitleLabel: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(hex: Colors.white, alpha: 0.5)
        return $0
    }(UIView())
    
    //MARK: Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor(hex: Colors.black)
        layoutElements()
        addTarget()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Configure
    func configureCell(task: Task) {
        isCompleted = task.completed
        titleLabel.text = task.title
        setupDescriptionLabel(description: task.description)
        formatAndSetDateLabel(date: task.date)
    }
    
    //MARK: Update
    private func updateForCompletionStatus(isCompleted: Bool) {
        checkmarkImageView.image = isCompleted ? UIImage(systemName: SystemSymbols.checkmarkCircle) : UIImage(systemName: SystemSymbols.circle)
        checkmarkImageView.tintColor = isCompleted ? UIColor(hex: Colors.yellow) : UIColor(hex: Colors.white, alpha: 0.5)
        titleLabel.textColor = isCompleted ? UIColor(hex: Colors.white, alpha: 0.5) : UIColor(hex: Colors.white)
        descriptionLabel.textColor = isCompleted ? UIColor(hex: Colors.white, alpha: 0.5) : UIColor(hex: Colors.white)
        separatorForTitleLabel.isHidden = !isCompleted
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
    
    //MARK: Target
    private func addTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkmarkImageViewTapped))
        checkmarkImageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Layout
    private func layoutElements() {
        layoutChekmarkImageView()
        layoutTitleLabel()
        layoutVStackView()
        layoutSeparatorForCell()
        layoutSeparatorForTitleLabel()
    }
    
    private func layoutChekmarkImageView() {
        contentView.addSubview(checkmarkImageView)
        
        NSLayoutConstraint.activate([
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 30),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 30),
            checkmarkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkmarkImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func layoutTitleLabel() {
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: checkmarkImageView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutVStackView() {
        [descriptionLabel, dateLabel].forEach { vStackView.addArrangedSubview($0) }
        contentView.addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            vStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            vStackView.leadingAnchor.constraint(equalTo: checkmarkImageView.trailingAnchor, constant: 5),
            vStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutSeparatorForCell() {
        contentView.addSubview(separatorForCell)
        
        NSLayoutConstraint.activate([
            separatorForCell.heightAnchor.constraint(equalToConstant: 1),
            separatorForCell.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorForCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorForCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutSeparatorForTitleLabel() {
        titleLabel.addSubview(separatorForTitleLabel)
        
        NSLayoutConstraint.activate([
            separatorForTitleLabel.heightAnchor.constraint(equalToConstant: 1),
            separatorForTitleLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            separatorForTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            separatorForTitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
}

//MARK: OBJC
extension TaskTableViewCell {
    @objc private func checkmarkImageViewTapped() {
        checkmarkImageViewAction?()
    }
}

