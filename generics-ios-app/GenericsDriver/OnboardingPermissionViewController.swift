//
//  OnboardingPermissionViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 23/07/2023.
//

import UIKit
import GenericsUIKit

final class OnboardingPermissionViewController: UIViewController {

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var mainButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var mainButtonBottomConstraint = mainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 100)
    private lazy var titleLabelTopConstraint = titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -300)

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            titleLabelTopConstraint
        ])

        titleLabel.text = "To start accepting orders give the app access to your location"
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        view.addSubview(mainButton)
        NSLayoutConstraint.activate([
            mainButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            mainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            mainButtonBottomConstraint,
            mainButton.heightAnchor.constraint(equalToConstant: .huge)
        ])
        mainButton.setTitle("Grant permission", for: .normal)

        navigationController?.isNavigationBarHidden = true

        mainButton.addAction(.init(handler: { _ in
            self.navigationController?.pushViewController(IdleViewController(), animated: true)
        }), for: .touchUpInside)
    }
}

extension OnboardingPermissionViewController: CustomInTransitinable {

    var transitionInDuration: TimeInterval {
        0.5
    }

    func transitionIn(completion: (() -> Void)?) {
        mainButtonBottomConstraint.constant = -.big
        titleLabelTopConstraint.constant = -.huge
        
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}

extension OnboardingPermissionViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.5
    }

    func transitionOut(completion: (() -> Void)?) {
        mainButtonBottomConstraint.constant = 100
        titleLabelTopConstraint.constant = -600

        UIView.animate(withDuration: transitionOutDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}
