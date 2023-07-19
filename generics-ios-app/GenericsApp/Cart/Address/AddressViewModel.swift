//
//  AddressViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 14/05/2023.
//

import Foundation
import CoreLocation
import Contacts
import MapKit

final class AddressViewModel {

    @Published var finishAddress: String?
    @Published var mapRegion: MKCoordinateRegion?

    private let geocoder = CLGeocoder()
    private let popMe: (() -> Void)?

    init(popMe: (() -> Void)?) {
        self.popMe = popMe
    }

    func submitTapped() {

    }

    func closeTapped() {
        popMe?()
    }

    func mapMoved(to coordinates: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)) { places, error in
            let place = places!.first!
            let formatter = CNPostalAddressFormatter()
            let addressString = formatter.string(from: place.postalAddress!)
            self.finishAddress = addressString
            //self.addressSheetView.finishAddress = addressString
            //self.addressSheetView.addressTextFieldValue = addressString
        }
    }

    func addressFieldChanged(to value: String?) {
        self.geocoder.geocodeAddressString(value ?? "") {
                (placemarks, error) in
                guard error == nil else {
                    print("Geocoding error: \(error!)")
                    return
                }
            let place = placemarks!.first!
            self.mapRegion = .init(center: place.location!.coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
            let formatter = CNPostalAddressFormatter()
            let addressString = formatter.string(from: place.postalAddress!)
            self.finishAddress = addressString
            }
    }
}
