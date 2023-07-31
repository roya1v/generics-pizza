//
//  WelcomeLabelView.swift
//  GenericsDriver
//
//  Created by Mike S. on 31/07/2023.
//

import UIKit

final class WelcomeLabelView: UIView {

    private let titles = [
        "Driver", "Superhero", "Foodman", "Lifesaver", "Pizza god", "Cycler", "Food Ninja", "Culinary Crusader",
        "Deliverance Dynamo", "Meal Maverick", "Gastronomic Guardian", "Sustenance Savior", "Flavor Warrior",
        "Gourmet Gladiator", "Culinary Champion", "Edible Enforcer", "Tasty Trailblazer", "Nourishment Navigator",
        "Epicurean Explorer", "Cuisine Conqueror", "Flavor Fighter", "Culinary Conductor", "Foodie Flyer",
        "Taste Titan", "Nutrient Knight", "Savory Specialist"
    ]

    private var staticLabel: UILabel = {
        let view = UILabel()
        return view
    }()

    private var dynamicLabel: UILabel = {
        let view = UILabel()
        return view
    }()

    private var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init() {
        super.init(frame: .zero)

        setupView()
    }

    private func setupView() {
        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        stackView.addArrangedSubview(staticLabel)

        let clippingView = UIView()
        dynamicLabel.translatesAutoresizingMaskIntoConstraints = false
        clippingView.addSubview(dynamicLabel)
        NSLayoutConstraint.activate([
            dynamicLabel.leadingAnchor.constraint(equalTo: clippingView.leadingAnchor),
            dynamicLabel.trailingAnchor.constraint(equalTo: clippingView.trailingAnchor),
            dynamicLabel.topAnchor.constraint(equalTo: clippingView.topAnchor),
            dynamicLabel.bottomAnchor.constraint(equalTo: clippingView.bottomAnchor),
        ])
        clippingView.clipsToBounds = true
        stackView.addArrangedSubview(clippingView)

        // Change to an even larger font
        staticLabel.font = .preferredFont(forTextStyle: .largeTitle)
        dynamicLabel.font = .preferredFont(forTextStyle: .largeTitle)
        dynamicLabel.adjustsFontSizeToFitWidth = true
        dynamicLabel.minimumScaleFactor = 0.2

        staticLabel.text = "Welcome"
        staticLabel.textAlignment = .center
        dynamicLabel.text = titles.randomElement()!
        dynamicLabel.textAlignment = .center
        dynamicLabel.clipsToBounds = true
        dynamicLabel.text = titles.randomElement()
        updateText()
    }

    func updateText() {
        Timer.scheduledTimer(withTimeInterval: Double.random(in: 1...3), repeats: false) { timer in
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.push
            animation.subtype = CATransitionSubtype.fromTop
            animation.duration = 0.5
            self.dynamicLabel.layer.add(animation, forKey: "animation")
            self.dynamicLabel.text = self.titles.randomElement()
            self.updateText()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
