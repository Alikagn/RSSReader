//
//  AddFeedViewController.swift
//  RSSReader
//
//  Created by Dmitry Batorevich on 26.04.2026.
//

import UIKit

protocol AddFeedDelegate: AnyObject {
    func didAddFeed(url: String, title: String)
    func didCancel()
}

final class AddFeedViewController: UIViewController {
    weak var delegate: AddFeedDelegate?
    
    private let urlTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите URL RSS-ленты"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Новая лента"
        view.addSubview(urlTextField)
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            urlTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            urlTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            urlTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            urlTextField.heightAnchor.constraint(equalToConstant: 44),
            
            addButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 20),
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupActions() {
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
    }
    
    @objc private func didTapAdd() {
        guard let urlString = urlTextField.text, !urlString.isEmpty else {
            showAlert(message: "Пожалуйста, введите URL")
            return
        }
        
        let title = "Новая лента" // Можно добавить отдельное поле для названия
        delegate?.didAddFeed(url: urlString, title: title)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
