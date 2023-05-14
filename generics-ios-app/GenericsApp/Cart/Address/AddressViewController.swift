//
//  AddressViewController.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 08/05/2023.
//

import UIKit
import MapKit
import Combine
import Contacts

final class AddressViewController: UIViewController {

    private let mapView: MKMapView = {
        let view = MKMapView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButtonView: UIButton = {
        var filled = UIButton.Configuration.filled()
        filled.image = UIImage(systemName: "chevron.left")
        filled.buttonSize = .medium
        filled.baseBackgroundColor = .systemBackground
        filled.baseForegroundColor = .black
        filled.imagePadding = 16.0
        filled.imagePlacement = .all

        let view = UIButton(configuration: filled)
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

    let model = AddressViewModel()

    var popMe: (() -> Void)?

    var constraint: NSLayoutConstraint! = nil

    var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.delegate = self
    }

    let geocoder = CLGeocoder()

    private func setupView() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(pinView)
        NSLayoutConstraint.activate([
            pinView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.heightAnchor.constraint(equalToConstant: 48.0),
            pinView.widthAnchor.constraint(equalToConstant: 40.0)
        ])
        pinView.image = UIImage(systemName: "mappin")
        pinView.tintColor = .systemRed

        view.addSubview(addressSheetView)
        NSLayoutConstraint.activate([
            addressSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        constraint = addressSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true

        view.addSubview(closeButtonView)
        NSLayoutConstraint.activate([
            closeButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            closeButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
        ])

        closeButtonView.addAction(.init(handler: { action in
            self.popMe?()
        }), for: .touchUpInside)

        addressSheetView.addressTextChanged.debounce(for: .seconds(2), scheduler: DispatchQueue.main).sink { value in
            self.geocoder.geocodeAddressString(value ?? "") {
                    (placemarks, error) in
                    guard error == nil else {
                        print("Geocoding error: \(error!)")
                        return
                    }
                let place = placemarks!.first!
                self.mapView.setRegion(.init(center: place.location!.coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0), animated: true)
                //placemarks!.first!.
                let formatter = CNPostalAddressFormatter()
                let addressString = formatter.string(from: place.postalAddress!)
                self.addressSheetView.finishAddress = addressString
                }
        }.store(in: &cancellable)

        addressSheetView.addressTextSubmited.sink { value in
            self.geocoder.geocodeAddressString(value ?? "") {
                    (placemarks, error) in
                    guard error == nil else {
                        print("Geocoding error: \(error!)")
                        return
                    }
                let place = placemarks!.first!
                self.mapView.setRegion(.init(center: place.location!.coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0), animated: true)
                //placemarks!.first!.
                let formatter = CNPostalAddressFormatter()
                let addressString = formatter.string(from: place.postalAddress!)
                self.addressSheetView.finishAddress = addressString
                }
        }.store(in: &cancellable)

        model.$finishAddress.receive(on: DispatchQueue.main).sink { address in
            self.addressSheetView.finishAddress = address
        }.store(in: &cancellable)

    }
}

extension AddressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.constraint.constant = 200
        view.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        constraint.constant = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }

        model.mapMoved(to: mapView.region.center)
    }
}
