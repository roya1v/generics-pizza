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

    var actionSlider: SliderToActionView = {
        let view = SliderToActionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var declineButton: UIButton = {
        let view = UIButton(configuration: .borderedTinted())
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

        actionSlider.title = "Slide to accept"
        addSubview(actionSlider)
        NSLayoutConstraint.activate([
            actionSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            actionSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            actionSlider.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .big)
        ])

        declineButton.setTitle("Decline", for: .normal)
        addSubview(declineButton)
        NSLayoutConstraint.activate([
            declineButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            declineButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            declineButton.topAnchor.constraint(equalTo: actionSlider.bottomAnchor, constant: .big),
            declineButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

    }
}
