//
//  LoginViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit
import GenericsUI
import GenericsUIKit
import Combine

final class LoginViewController: UIViewController {

    private var welcomeLabel: WelcomeLabelView = {
        let view = WelcomeLabelView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

     private var emailTextField: TextField = {
        let view = TextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var passwordTextField: TextField = {
        let view = TextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var loginButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var loginButtonBottomConstraint = loginButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -.big)
    private lazy var welcomeLabelTopConstraint = welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -.big)

    private let model = LoginViewModel()
    private var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBinding()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(welcomeLabel)
        NSLayoutConstraint.activate([
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            welcomeLabelTopConstraint
        ])

        emailTextField.placeholder = "Email"
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .username
        view.addSubview(emailTextField)
        NSLayoutConstraint.activate([
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            emailTextField.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: .big)
        ])

        passwordTextField.placeholder = "Password"
        emailTextField.keyboardType = .asciiCapable
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
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
    }

    private func setupBinding() {
        loginButton.addAction(.init(handler: { _ in
            self.view.endEditing(true)
            self.model.login(email: self.emailTextField.text!, password: self.passwordTextField.text!)
        }), for: .touchUpInside)

        model
            .$state
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                case .ready:
                    self.loginButton.setTitle("Login", for: .normal)
                case .loading:
                    self.loginButton.setTitle("Loading...", for: .normal)
                case .error:
                    let alert = UIAlertController(title: "Ooops!",
                                                  message: "An error happened while logging in",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.loginButton.setTitle("Login", for: .normal)
                }
            }
            .store(in: &cancellable)
    }
}

extension LoginViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.5
    }

    func transitionOut(completion: (() -> Void)?) {
        loginButtonBottomConstraint.constant = 100
        welcomeLabelTopConstraint.constant = -300

        UIView.animate(withDuration: transitionOutDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}
