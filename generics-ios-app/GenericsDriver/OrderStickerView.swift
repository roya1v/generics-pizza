//
//  OrderStickerView.swift
//  GenericsDriver
//
//  Created by Mike S. on 02/08/2023.
//

import UIKit

final class OrderStickerView: UIView {

    var nameLabel: UILabel = {
        let view = UILabel()
        return view
    }()

    var orderNumberLabel: UILabel = {
        let view = UILabel()
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
        backgroundColor = .init(red: 245.0 / 255.0, green: 245.0 / 255.0, blue: 220.0 / 255.0, alpha: 1.0)
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(orderNumberLabel)
    }
}
