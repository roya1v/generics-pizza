//
//  AddressViewController.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 08/05/2023.
//

import UIKit
import MapKit

final class AddressViewController: UIViewController {

    private let mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButtonView: UIButton = {
        let view = UIButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let pinView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let addressSheetView: AddressSheetView = {
        let view = AddressSheetView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    var popMe: (() -> Void)?

    var constraint: NSLayoutConstraint! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        mapView.delegate = self
    }

    private func setupView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(addressSheetView)
        NSLayoutConstraint.activate([
            addressSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //addressSheetView.heightAnchor.constraint(equalToConstant: 300.0)
        ])
        constraint = addressSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true
    }
}

extension AddressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.constraint.constant = 200
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn) {
            self.view.layoutIfNeeded()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        constraint.constant = 0
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut) {
            self.view.layoutIfNeeded()
        }
    }
}
