//
//  BackButtonView.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

final class BackButtonView: UIView {
    
    //MARK: UI
    private let imageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(systemName: SystemSymbols.chevronLeft)
        $0.tintColor = UIColor(hex: Colors.yellow)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        return $0
    }(UIImageView())
    
    private let titleLabel: UILabel = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.numberOfLines = 1
        $0.textColor = UIColor(hex: Colors.yellow)
        $0.font = .systemFont(ofSize: 17, weight: .regular)
        $0.text = LabelNames.back
        return $0
    }(UILabel())
    
    private let hStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .horizontal
        $0.spacing = 5
        return $0
    }(UIStackView())
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutElements()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Layout
    private func layoutElements() {
        [imageView, titleLabel].forEach { hStackView.addArrangedSubview($0) }
        addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 17),
            imageView.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
          
            hStackView.topAnchor.constraint(equalTo: topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hStackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}
