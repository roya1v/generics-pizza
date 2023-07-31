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
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .big)
        ])

        titleLabel.text = "To start accepting orders give the app access to your location"
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        view.addSubview(mainButton)
        NSLayoutConstraint.activate([
            mainButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            mainButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            mainButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.big),
            mainButton.heightAnchor.constraint(equalToConstant: .huge)
        ])
        mainButton.setTitle("Grant permission", for: .normal)

        navigationController?.isNavigationBarHidden = true

        mainButton.addAction(.init(handler: { _ in
            self.navigationController?.pushViewController(IdleViewController(), animated: true)
        }), for: .touchUpInside)
    }
}
