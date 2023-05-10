//
//  AddressSheetView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 09/05/2023.
//

import UIKit
import Combine

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

    let addressTextField: UITextField = {
        let view = UITextField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let routeStartStep: RouteStepView = {
        let view = RouteStepView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let routeFinishStep: RouteStepView = {
        let view = RouteStepView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var texting = PassthroughSubject<String?, Never>()

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
        addressTextField.borderStyle = .roundedRect

        addSubview(routeStartStep)
        NSLayoutConstraint.activate([
            routeStartStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeStartStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeStartStep.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 16.0)
        ])
        routeStartStep.titleText = "Restaurant"
        routeStartStep.subtitleText = "Generic's street 8"
        routeStartStep.image = UIImage(named: "destination_icon")

        addSubview(routeFinishStep)
        NSLayoutConstraint.activate([
            routeFinishStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeFinishStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeFinishStep.topAnchor.constraint(equalTo: routeStartStep.bottomAnchor, constant: 16.0),
            routeFinishStep.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16.0)
        ])
        routeFinishStep.titleText = "You"
        routeFinishStep.subtitleText = "Generic's street 9"
        routeFinishStep.image = UIImage(named: "location_icon")

        addressTextField.addAction(.init(handler: { action in
            self.texting.send(self.addressTextField.text)
        }), for: .editingChanged)
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

    var titleText: String? {
        get {
            titleView.text
        }
        set {
            titleView.text = newValue
        }
    }

    var subtitleText: String? {
        get {
            subtitleView.text
        }
        set {
            subtitleView.text = newValue
        }
    }

    var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            //imageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / 5.0)
        ])
        imageView.backgroundColor = .red
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.layer.cornerRadius = 16.0
        imageView.layer.masksToBounds = true

        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8.0),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        titleView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        //titleView.font = .preferredFont(forTextStyle: .title2)

        addSubview(subtitleView)
        NSLayoutConstraint.activate([
            subtitleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8.0),
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 2.0),
            subtitleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4.0)
        ])

        subtitleView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        subtitleView.textColor = .systemGray

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
