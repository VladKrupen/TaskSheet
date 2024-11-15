//
//  TaskPageViewController.swift
//  TaskSheet
//
//  Created by Vlad on 15.11.24.
//

import UIKit

protocol TaskPageViewProtocol: AnyObject {
    
}

final class TaskPageViewController: UIViewController {
    
    var presenter: TaskPagePresenterProtocol?
    private let contentView = TaskPageView()
    
    private let backButtonView = BackButtonView()
    
    //MARK: Life cycle
    override func loadView() {
        super.loadView()
        view = contentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
    }
    
    //MARK: Setup
    private func setupNavigationController() {
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButtonView)
        backButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonViewTapped)))
    }
}

//MARK: TasksViewProtocol
extension TaskPageViewController: TaskPageViewProtocol {
    
}

//MARK: OBJC
extension TaskPageViewController {
    @objc private func backButtonViewTapped() {
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.backButtonView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { [weak self] _ in
            
            UIView.animate(withDuration: 0.1) {
                self?.backButtonView.transform = .identity
            }
        }
    }
}
