//
//  AddressSheetView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 09/05/2023.
//

import UIKit
import Combine
import GenericsUI

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

    private let captionLabel: UILabel = {
        let view = UILabel(frame: .zero)
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

    var addressTextChanged = PassthroughSubject<String?, Never>()
    var addressTextSubmited = PassthroughSubject<String?, Never>()

    var addressTextFieldValue: String? {
        get {
            addressTextField.text
        }
        set {
            addressTextField.text = newValue
        }
    }

    var startAddress: String? {
        didSet {
            if let finishAddress {
                routeStartStep.subtitleText = finishAddress
                showSteps()

            } else {
                routeStartStep.isHidden = true
            }
        }
    }

    var finishAddress: String? {
        didSet {
            if let finishAddress {
                routeFinishStep.subtitleText = finishAddress
                showSteps()
            } else {
                routeFinishStep.isHidden = true
            }
        }
    }

    init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
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

        addSubview(addressTextField)
        NSLayoutConstraint.activate([
            addressTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            addressTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            addressTextField.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 16.0),
            addressTextField.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor, constant: -16.0)
        ])
        addressTextField.borderStyle = .roundedRect
        addressTextField.addAction(.init(handler: { action in
            self.addressTextChanged.send(self.addressTextField.text)
        }), for: .editingChanged)
        addressTextField.addAction(.init(handler: { action in
            self.addressTextSubmited.send(self.addressTextField.text)
            self.addressTextField.resignFirstResponder()
        }), for: .primaryActionTriggered)

        addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            submitButton.heightAnchor.constraint(equalToConstant: 64.0),
            submitButton.topAnchor.constraint(greaterThanOrEqualTo: addressTextField.bottomAnchor, constant: 16.0)
        ])
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.backgroundColor = .black
        submitButton.layer.cornerRadius = 32.0
        submitButton.isEnabled = false

        addSubview(captionLabel)
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0),
            captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            captionLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 8.0),
        ])
        captionLabel.text = "Your driver will receive both the pin location and address"
        captionLabel.font = .preferredFont(forTextStyle: .caption1)
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 0
    }

    func showSteps() {
        addSubview(routeStartStep)
        NSLayoutConstraint.activate([
            routeStartStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeStartStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeStartStep.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: 16.0)
        ])
        routeStartStep.titleText = "Restaurant"
        routeStartStep.subtitleText = " "
        routeStartStep.image = UIImage(named: "destination_icon")
        routeStartStep.isHidden = false

        addSubview(routeFinishStep)
        NSLayoutConstraint.activate([
            routeFinishStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            routeFinishStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            routeFinishStep.topAnchor.constraint(equalTo: routeStartStep.bottomAnchor, constant: 16.0),
            routeFinishStep.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16.0)
        ])
        routeFinishStep.titleText = "You"
        routeFinishStep.image = UIImage(named: "location_icon")
        routeFinishStep.isHidden = false
    }

    func hideSteps() {

    }
}
