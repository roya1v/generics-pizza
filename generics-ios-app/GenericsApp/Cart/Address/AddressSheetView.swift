//
//  AddressSheetView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 09/05/2023.
//

import UIKit

final class AddressSheetView: UIView {

    private let titleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let submitButton: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let addressTextField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let routeStartStep: RouteStepView = {
        let view = RouteStepView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let routeFinishStep: RouteStepView = {
        let view = RouteStepView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        layer.cornerRadius = 32.0

        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 16.0),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16.0)
        ])
        titleView.text = "Delivery address"
        titleView.font = .preferredFont(forTextStyle: .title1)

        addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            submitButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0),
            submitButton.heightAnchor.constraint(equalToConstant: 64.0)
        ])
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .black
        submitButton.layer.cornerRadius = 32.0

        addSubview(addressTextField)
        NSLayoutConstraint.activate([
            addressTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            addressTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            addressTextField.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16.0),
        ])
        addressTextField.backgroundColor = .red

        addSubview(routeStartStep)
        NSLayoutConstraint.activate([
            routeStartStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeStartStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeStartStep.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 16.0),
            //routeStartStep.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16.0)
        ])

        addSubview(routeFinishStep)
        NSLayoutConstraint.activate([
            routeFinishStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeFinishStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeFinishStep.topAnchor.constraint(equalTo: routeStartStep.bottomAnchor, constant: 16.0),
            routeFinishStep.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16.0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class RouteStepView: UIView {

    private let imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let subtitleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / 5.0)
        ])
        imageView.backgroundColor = .red

        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8.0),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8.0),
        ])
        titleView.backgroundColor = .purple
        titleView.text = "TEST"

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
