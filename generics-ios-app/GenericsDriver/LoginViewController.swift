//
//  LoginViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit
import GenericsUI

final class LoginViewController: UIViewController {

    private var emailTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var passwordTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var loginButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        emailTextField.borderStyle = .roundedRect
        emailTextField.placeholder = "Email"
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120.0)
        ])

        passwordTextField.borderStyle = .roundedRect
        passwordTextField.placeholder = "Password"
        view.addSubview(passwordTextField)
        NSLayoutConstraint.activate([
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: .big)
        ])

        loginButton.setTitle("Login", for: .normal)
        view.addSubview(loginButton)
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.big),
            loginButton.heightAnchor.constraint(equalToConstant: .huge)
        ])


        // Temporary
        loginButton.addAction(.init(handler: { _ in
            self.navigationController?.pushViewController(OnboardingPermissionViewController(), animated: true)
        }), for: .touchUpInside)
    }
}
