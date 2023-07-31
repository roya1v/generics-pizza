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

    private lazy var loginButtonBottomConstraint = loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.big)
    private lazy var emailTextFieldTopConstraint = emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120.0)

    private func setupView() {
        view.backgroundColor = .systemBackground

        emailTextField.borderStyle = .roundedRect
        emailTextField.placeholder = "Email"
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            emailTextFieldTopConstraint
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
            loginButtonBottomConstraint,
            loginButton.heightAnchor.constraint(equalToConstant: .huge)
        ])

        // Temporary
        loginButton.addAction(.init(handler: { _ in
            self.navigationController?.pushViewController(OnboardingPermissionViewController(), animated: true)
        }), for: .touchUpInside)
    }
}

extension LoginViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.5
    }

    func transitionOut(completion: (() -> Void)?) {
        loginButtonBottomConstraint.constant = 100
        emailTextFieldTopConstraint.constant = -200

        UIView.animate(withDuration: transitionOutDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}

