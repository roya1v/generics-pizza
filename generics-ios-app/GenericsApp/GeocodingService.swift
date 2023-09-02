//
//  GeocodingService.swift
//  GenericsApp
//
//  Created by Mike S. on 02/09/2023.
//

import Foundation
import MapKit
import Contacts

public func buildGeocodingService() -> GeocodingService {
    GeocodingServiceImpl()
}

public protocol GeocodingService {
    func getCoordinate(for address: String) async throws -> CLLocationCoordinate2D?
    func getAddress(for coordinate: CLLocationCoordinate2D) async throws -> String?
}

final class GeocodingServiceImpl: GeocodingService {

    private let geocoder = CLGeocoder()
    private let formatter = CNPostalAddressFormatter()

    func getCoordinate(for address: String) async throws -> CLLocationCoordinate2D? {
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(address) { places, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let places,
                   let place = places.first {
                    continuation.resume(returning: place.location?.coordinate)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    func getAddress(for coordinate: CLLocationCoordinate2D) async throws -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.reverseGeocodeLocation(location) { places, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let places,
                   let place = places.first,
                   let address = place.postalAddress {
                    continuation.resume(returning: self.formatter.string(from: address))
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
