//
//  SliderToActionView.swift
//  GenericsDriver
//
//  Created by Mike S. on 29/08/2023.
//

import UIKit
import GenericsUI

// TODO: Make dismiss interactable
public final class SliderToActionView: UIView {

    private var sliderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var arrowView: UIImageView = {
        let view = UIImageView()
        view.image = .init(systemName: "chevron.right")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var gradient = makeGradient()
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))

    private lazy var sliderConstraint = sliderView.leadingAnchor.constraint(equalTo: leadingAnchor)

    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    public var onAction: (() -> Void)?

    public init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = .normal
        backgroundColor = .lightGray
        clipsToBounds = true

        addSubview(sliderView)
        sliderView.layer.addSublayer(gradient)
        gradient.cornerRadius = .normal
        sliderView.addSubview(arrowView)
        sliderView.addSubview(titleLabel)
        sliderView.addGestureRecognizer(panGestureRecognizer)

        NSLayoutConstraint.activate([
            sliderConstraint,
            sliderView.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor),
            sliderView.topAnchor.constraint(equalTo: topAnchor),
            sliderView.bottomAnchor.constraint(equalTo: bottomAnchor),

            arrowView.leadingAnchor.constraint(equalTo: sliderView.leadingAnchor, constant: .normal),
            arrowView.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: .normal),
            arrowView.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: -.normal),

            titleLabel.leadingAnchor.constraint(equalTo: arrowView.trailingAnchor, constant: .normal),
            titleLabel.topAnchor.constraint(equalTo: sliderView.topAnchor, constant: .normal),
            titleLabel.bottomAnchor.constraint(equalTo: sliderView.bottomAnchor, constant: -.normal),
            titleLabel.trailingAnchor.constraint(equalTo: sliderView.trailingAnchor, constant: -.normal)
        ])

        titleLabel.textColor = .white
        arrowView.tintColor = .white
        arrowView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        gradient.frame = bounds
    }

    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        guard sender.state != .ended else {
            sliderConstraint.constant = 0
            UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
                self.layoutIfNeeded()
            }
            return
        }
        let translatedPoint = sender.translation(in: self).x
        if translatedPoint > frame.width * 0.7 {
            onAction?()
            return
        }
        sliderConstraint.constant = translatedPoint
    }

    private func makeGradient() -> CAGradientLayer {
        let gradient = CAGradientLayer()
        let color1 = UIColor(red: 0.21, green: 0.82, blue: 0.86, alpha: 1.00).cgColor
        let color2 = UIColor(red: 0.36, green: 0.53, blue: 0.90, alpha: 1.00).cgColor

        gradient.colors = [color2, color1, color2, color1, color2]
        gradient.frame = frame
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.drawsAsynchronously = true
        gradient.locations = [0.4, 0.5, 0.6]

        let gradientAnimation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        gradientAnimation.duration = 3.0
        gradientAnimation.fromValue = [-1.0, -0.5, 0.0, 0.5, 1.0]
        gradientAnimation.toValue = [0.0, 0.5, 1.0, 1.5, 2.0]
        gradientAnimation.repeatCount = .infinity
        gradient.add(gradientAnimation, forKey: "colors")
        return gradient
    }
}
