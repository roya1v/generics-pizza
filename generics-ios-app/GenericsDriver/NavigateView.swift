//
//  NavigateView.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit

final class NavigateView: UIView {

    var actionButton: UIButton = {
        let view = UIButton(configuration: .borderedProminent())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var appleMapsButton: UIButton = {
        let view = UIButton(configuration: .plain())
        return view
    }()

    private var googleMapsButton: UIButton = {
        let view = UIButton(configuration: .plain())
        return view
    }()

    private var wazeMapsButton: UIButton = {
        let view = UIButton(configuration: .plain())
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
        actionButton.setTitle("Pick up order", for: .normal)
        addSubview(actionButton)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            actionButton.topAnchor.constraint(equalTo: topAnchor, constant: .big)
        ])

        titleLabel.text = "Open navigation in:"
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            titleLabel.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: .big)
        ])

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .big),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.big)
        ])

        [appleMapsButton, googleMapsButton, wazeMapsButton].forEach { button in
            stackView.addArrangedSubview(button)
            button.setImage(.init(systemName: "map"), for: .normal)
        }
    }
}
