//
//  AcceptOrderView.swift
//  GenericsDriver
//
//  Created by Mike S. on 02/08/2023.
//

import UIKit

final class AcceptOrderView: UIView {

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //TODO: Replace with slide-to-action
    var actionButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var declineButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        titleLabel.text = "Reward: 777$"
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: .big)
        ])

        actionButton.setTitle("Slide to accept", for: .normal)
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            actionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .big)
        ])

        declineButton.setTitle("Decline", for: .normal)
        addSubview(declineButton)
        NSLayoutConstraint.activate([
            declineButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            declineButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            declineButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: .big),
            declineButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
}
