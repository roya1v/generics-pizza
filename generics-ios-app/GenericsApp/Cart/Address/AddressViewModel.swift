//
//  AddressViewModel.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 14/05/2023.
//

import Foundation
import CoreLocation
import Contacts

final class AddressViewModel {

    let geocoder = CLGeocoder()

    @Published var finishAddress: String?

    func submitTapped() {

    }

    func closeTapped() {
        
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
}
