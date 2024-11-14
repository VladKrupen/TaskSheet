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
        $0.text = LabelNames.tasks
        return $0
    }(UILabel())
    
    let searchField: SearchField = {
        $0.isEmptyText = true
        $0.setPlaceholder(placeholder: Placeholders.search)
        return $0
    }(SearchField())
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: Colors.black)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Layout
    private func layoutElements() {
        layoutTitleLabel()
        layoutSearchBar()
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
}
