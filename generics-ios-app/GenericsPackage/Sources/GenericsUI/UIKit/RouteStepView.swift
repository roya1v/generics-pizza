//
//  RouteStepView.swift
//  
//
//  Created by Mike Shevelinsky on 14/05/2023.
//

#if os(iOS)



import UIKit

final public class RouteStepView: UIView {

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

    public var titleText: String? {
        get {
            titleView.text
        }
        set {
            titleView.text = newValue
        }
    }

    public var subtitleText: String? {
        get {
            subtitleView.text
        }
        set {
            subtitleView.text = newValue
        }
    }

    public var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
        }
    }

    public init() {
        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        imageView.backgroundColor = .red
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.layer.cornerRadius = 16.0
        imageView.layer.masksToBounds = true

        addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: .normal),
            titleView.topAnchor.constraint(equalTo: topAnchor, constant: .small),
            titleView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        titleView.setContentHuggingPriority(.defaultHigh, for: .vertical)

        addSubview(subtitleView)
        NSLayoutConstraint.activate([
            subtitleView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: .normal),
            subtitleView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: .tiny),
            subtitleView.trailingAnchor.constraint(equalTo: trailingAnchor),
            subtitleView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.small)
        ])

        subtitleView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        subtitleView.textColor = .systemGray
    }
}

#endif
