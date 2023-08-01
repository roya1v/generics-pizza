//
//  IdleViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit
import GenericsUIKit

final class IdleViewController: UIViewController {

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var prettyAnimationView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        view.backgroundColor = .systemBackground

        view.addSubview(prettyAnimationView)
        NSLayoutConstraint.activate([
            prettyAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            prettyAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            prettyAnimationView.heightAnchor.constraint(equalTo: prettyAnimationView.widthAnchor)
        ])

        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .big),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.big),
            titleLabel.bottomAnchor.constraint(equalTo: prettyAnimationView.topAnchor, constant: -.big)
        ])

        titleLabel.text = "Waiting for orders"
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.textAlignment = .center

        navigationController?.isNavigationBarHidden = true


        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(trigger))
        prettyAnimationView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(trigger))
    }

    @objc func trigger() {
        self.navigationController?.pushViewController(MapNavigationViewController(), animated: true)
    }
}

extension IdleViewController: CustomInTransitinable {
    var transitionInDuration: TimeInterval {
        0.5
    }

    func transitionIn(completion: (() -> Void)?) {
        let newConstraint = prettyAnimationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
        newConstraint.isActive = true
        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}

extension IdleViewController: CustomOutTransitinable {
    var transitionOutDuration: TimeInterval {
        0.0
    }

    func transitionOut(completion: (() -> Void)?) {
        completion?()
    }
}
