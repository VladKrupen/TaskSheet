//
//  TaskPageView.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

final class TaskPageView: UIView {
    
    private var lastContentOffset: CGFloat = 0
    
    //MARK: UI
    private lazy var titleField: UITextField = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 34, weight: .bold)
        $0.tintColor = UIColor(hex: Colors.white)
        $0.textColor = UIColor(hex: Colors.white)
        if let placeholderColor = UIColor(hex: Colors.white, alpha: 0.5) {
            $0.attributedPlaceholder = NSAttributedString(string: Placeholders.title, attributes: [.foregroundColor: placeholderColor])
        }
        $0.delegate = self
        return $0
    }(UITextField())
    
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
        $0.spacing = 8
        return $0
    }(UIStackView())
    
    private lazy var descriptionTextView: UITextView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .natural
        $0.font = .systemFont(ofSize: 18, weight: .regular)
        $0.textColor = UIColor(hex: Colors.white, alpha: 0.5)
        $0.tintColor = UIColor(hex: Colors.white)
        $0.backgroundColor = UIColor(hex: Colors.black)
        $0.text = Placeholders.description
        $0.delegate = self
        return $0
    }(UITextView())
    
    //MARK: Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: Colors.black)
        layoutElements()
        scrollingWhenOpeningKeyboard()
        setupPanGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Setup
    private func scrollingWhenOpeningKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupPanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    private func formatAndSetDateLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    //MARK: Layout
    private func layoutElements() {
        layoutVStackView()
        layoutDescriptionTextView()
    }
    
    private func layoutVStackView() {
        [titleField, dateLabel].forEach { vStackView.addArrangedSubview($0) }
        addSubview(vStackView)
        
        NSLayoutConstraint.activate([
            vStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            vStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            vStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
    
    private func layoutDescriptionTextView() {
        addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: vStackView.bottomAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

//MARK: OBJC
extension TaskPageView {
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight - 20, right: 0)
            descriptionTextView.contentInset = contentInset
            descriptionTextView.scrollIndicatorInsets = contentInset
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        descriptionTextView.contentInset = .zero
        descriptionTextView.contentInset = .zero
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translationDescriptionTextView = gesture.translation(in: descriptionTextView)
        let translationTitleField = gesture.translation(in: titleField)
        if gesture.state == .changed {
            if translationDescriptionTextView.y > 0 && lastContentOffset <= 0 {
                descriptionTextView.resignFirstResponder()
            }
            if translationTitleField.y > 0 && lastContentOffset <= 0 {
                titleField.resignFirstResponder()
            }
        }
        lastContentOffset = translationDescriptionTextView.y
    }
}

//MARK: UITextFieldDelegate
extension TaskPageView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateTitleFieldIfNeeded(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func updateTitleFieldIfNeeded(textField: UITextField) {
        if textField == titleField {
            guard let text = textField.text else {
                return
            }
            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                textField.text = ""
                return
            }
            textField.text = text.trimmingCharacters(in: .whitespaces)
        }
    }
}

//MARK: UITextViewDelegate
extension TaskPageView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        hidePlaceholderForTextView(textView: textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateDescriptionTextViewIfNeeded(textView: textView)
        showPlaceholderForTextView(textView: textView)
    }
    
    private func showPlaceholderForTextView(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Placeholders.description
            textView.textColor = UIColor(hex: Colors.white, alpha: 0.5)
        }
        textView.resignFirstResponder()
    }
    
    private func hidePlaceholderForTextView(textView: UITextView) {
        if textView.text == Placeholders.description {
            textView.text = nil
            textView.textColor = UIColor(hex: Colors.white)
        }
    }
    
    private func updateDescriptionTextViewIfNeeded(textView: UITextView) {
        if textView == descriptionTextView {
            guard let text = descriptionTextView.text else {
                return
            }
            guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                descriptionTextView.text = ""
                return
            }
            descriptionTextView.text = text.trimmingCharacters(in: .whitespaces)
        }
    }
}

//MARK: UIGestureRecognizerDelegate
extension TaskPageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
