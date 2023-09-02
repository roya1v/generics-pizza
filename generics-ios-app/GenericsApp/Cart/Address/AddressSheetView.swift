//
//  AddressSheetView.swift
//  GenericsApp
//
//  Created by Mike S. on 09/05/2023.
//

import UIKit
import Combine
import GenericsUI
import GenericsUIKit

final class AddressSheetView: UIView {

    private let titleView: UILabel = {
        let view = UILabel(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let submitButton: UIButton = {
        let view = UIButton(configuration: .primary())
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

    let addressTextChanged = PassthroughSubject<String?, Never>()
    let addressTextSubmited = PassthroughSubject<String?, Never>()

    var addressTextFieldValue: String? {
        get {
            addressTextField.text
        }
        set {
            addressTextField.text = newValue
        }
    }

    var isSubmitEnabled: Bool {
        get {
            submitButton.isEnabled
        }
        set {
            submitButton.isEnabled = newValue
        }
    }

    var startAddress: String? {
        didSet {
            if let startAddress {
                routeStartStep.subtitleText = startAddress
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

    var onSubmit: (() -> Void)?

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
            titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: .big),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: .big)
        ])
        titleView.text = "Delivery address"
        titleView.font = .preferredFont(forTextStyle: .title1)

        addSubview(addressTextField)
        NSLayoutConstraint.activate([
            addressTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            addressTextField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            addressTextField.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: .big),
            addressTextField.bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor, constant: -.big)
        ])
        addressTextField.borderStyle = .roundedRect
        addressTextField.placeholder = "Details"
        addressTextField.addAction(.init(handler: { action in
            self.addressTextChanged.send(self.addressTextField.text)
        }), for: .editingChanged)
        addressTextField.addAction(.init(handler: { action in
            self.addressTextSubmited.send(self.addressTextField.text)
            self.addressTextField.resignFirstResponder()
        }), for: .primaryActionTriggered)

        addSubview(submitButton)
        NSLayoutConstraint.activate([
            submitButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            submitButton.topAnchor.constraint(greaterThanOrEqualTo: addressTextField.bottomAnchor, constant: .big)
        ])
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addAction(.init(handler: { _ in
            self.onSubmit?()
        }), for: .touchUpInside)

        addSubview(captionLabel)
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32.0),
            captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32.0),
            captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.big),
            captionLabel.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: .normal),
        ])
        captionLabel.text = "Your driver will receive both the pin location and details"
        captionLabel.font = .preferredFont(forTextStyle: .caption1)
        captionLabel.textAlignment = .center
        captionLabel.numberOfLines = 0
    }

    func showSteps() {
        addSubview(routeStartStep)
        NSLayoutConstraint.activate([
            routeStartStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            routeStartStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            routeStartStep.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: .big)
        ])
        routeStartStep.titleText = "Restaurant"
        routeStartStep.image = UIImage(named: "destination_icon")
        routeStartStep.isHidden = false

        addSubview(routeFinishStep)
        NSLayoutConstraint.activate([
            routeFinishStep.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .big),
            routeFinishStep.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.big),
            routeFinishStep.topAnchor.constraint(equalTo: routeStartStep.bottomAnchor, constant: .big),
            routeFinishStep.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -.big)
        ])
        routeFinishStep.titleText = "You"
        routeFinishStep.image = UIImage(named: "location_icon")
        routeFinishStep.isHidden = false
    }
}
