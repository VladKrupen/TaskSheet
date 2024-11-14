//
//  SearchField.swift
//  TaskSheet
//
//  Created by Vlad on 14.11.24.
//

import UIKit

final class SearchField: UITextField {
    
    var isEmptyText: Bool? {
        willSet {
            guard let newValue else { return }
            newValue ? setImage(image: SystemSymbols.microphoneFill) : setImage(image: SystemSymbols.xCircle)
            rightImageView.contentMode = newValue ? .scaleAspectFill : .scaleAspectFit
        }
    }
    
    private let leftStepView = UIView(frame: .init(x: 0, y: 0, width: 33, height: 36))
    private let rightStepView = UIView(frame: .init(x: 0, y: 0, width: 33, height: 36))
    
    private let searchImageView: UIImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: SystemSymbols.magnifyingglass)?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = UIColor(hex: Colors.white, alpha: 0.5)
        return $0
    }(UIImageView(frame: .init(x: 6.5, y: 7.0, width: 20, height: 22)))
    
    private let rightImageView: UIImageView = {
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
        return $0
    }(UIImageView(frame: .init(x: 8, y: 7.0, width: 17, height: 22)))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSearchField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setPlaceholder(placeholder: String) {
        guard let placeholderColor = UIColor(hex: Colors.white, alpha: 0.5) else { return }
        self.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
    }
    
    func addTapGesture(target: Any?, action: Selector?) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        rightImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setImage(image: String) {
        rightImageView.image = UIImage(systemName: image)?.withRenderingMode(.alwaysTemplate)
        rightImageView.tintColor = UIColor(hex: Colors.white, alpha: 0.5)
    }
    
    private func setupSearchField() {
        translatesAutoresizingMaskIntoConstraints = false
        returnKeyType = .search
        layer.cornerRadius = 10
        backgroundColor = UIColor(hex: Colors.gray)
        tintColor = UIColor(hex: Colors.white)
        textColor = UIColor(hex: Colors.white)
        leftView = leftStepView
        leftViewMode = .always
        rightView = rightStepView
        rightViewMode = .always
        leftStepView.addSubview(searchImageView)
        rightStepView.addSubview(rightImageView)
    }
}
