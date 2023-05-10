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

    var cancellable = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
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

        view.addSubview(addressSheetView)
        NSLayoutConstraint.activate([
            addressSheetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addressSheetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //addressSheetView.heightAnchor.constraint(equalToConstant: 300.0)
        ])
        constraint = addressSheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        constraint.isActive = true

        view.addSubview(closeButtonView)
        NSLayoutConstraint.activate([
            closeButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8.0),
            closeButtonView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8.0),
        ])

        closeButtonView.backgroundColor = .white
        closeButtonView.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        closeButtonView.tintColor = .black
        closeButtonView.configuration?.contentInsets = .init(top: 18.0, leading: 18.0, bottom: 18.0, trailing: 18.0)

        addressSheetView.texting.debounce(for: .seconds(2), scheduler: DispatchQueue.main).sink { value in
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
                self.addressSheetView.routeFinishStep.subtitleText = addressString
                }
        }.store(in: &cancellable)

        view.addSubview(pinView)
        NSLayoutConstraint.activate([
            pinView.bottomAnchor.constraint(equalTo: view.centerYAnchor),
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.heightAnchor.constraint(equalToConstant: 80.0),
            pinView.widthAnchor.constraint(equalTo: pinView.heightAnchor)
        ])
        pinView.image = UIImage(systemName: "mappin")
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


        geocoder.reverseGeocodeLocation(CLLocation(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude)) { places, error in
            let place = places!.first!
            let formatter = CNPostalAddressFormatter()
            let addressString = formatter.string(from: place.postalAddress!)
            self.addressSheetView.routeFinishStep.subtitleText = addressString
            self.addressSheetView.addressTextField.text = addressString
        }
    }
}
