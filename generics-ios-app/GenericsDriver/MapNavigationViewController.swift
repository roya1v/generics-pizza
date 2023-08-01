//
//  MapNavigationViewController.swift
//  GenericsDriver
//
//  Created by Mike S. on 23/07/2023.
//

import UIKit
import MapKit

final class MapNavigationViewController: UIViewController {

    private var mapView: MKMapView = {
        let view = MKMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var sheetView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private lazy var sheetConstraint = view.bottomAnchor.constraint(equalTo: sheetView.topAnchor)
    private lazy var mapConstraint = mapView.topAnchor.constraint(equalTo: view.bottomAnchor)

    private func setupView() {
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapConstraint,
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let navigateTo = NavigateView()
        navigateTo.translatesAutoresizingMaskIntoConstraints = false
        sheetView.addSubview(navigateTo)
        NSLayoutConstraint.activate([
            navigateTo.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            navigateTo.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            navigateTo.topAnchor.constraint(equalTo: sheetView.topAnchor),
            navigateTo.bottomAnchor.constraint(equalTo: sheetView.safeAreaLayoutGuide.bottomAnchor),
        ])
        sheetView.backgroundColor = .systemBackground

        view.addSubview(sheetView)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: sheetView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: sheetView.trailingAnchor),
            sheetConstraint,
        ])
    }
}

extension MapNavigationViewController: CustomInTransitinable {
    var transitionInDuration: TimeInterval {
        0.5
    }

    func transitionIn(completion: (() -> Void)?) {
        sheetConstraint.isActive = false
        view.bottomAnchor.constraint(equalTo: sheetView.bottomAnchor).isActive = true

        mapConstraint.isActive = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true

        UIView.animate(withDuration: transitionInDuration, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion?()
        }
    }
}
