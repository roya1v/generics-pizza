//
//  AddressViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 14/05/2023.
//

import Foundation
import CoreLocation
import MapKit
import Factory
import SharedModels

final class AddressViewModel {

    @Published private(set) var finishAddress: String?
    @Published private(set) var restaurantAddress: String?
    @Published private(set) var mapRegion: MKCoordinateRegion?
    @Published private(set) var restaurantCoordinate: CLLocationCoordinate2D?
    @Published private(set) var isSubmitEnabled = false

    private var orderCoordinate: CLLocationCoordinate2D?
    private var orderDetails = ""

    private let popMe: (() -> Void)?

    @Injected(\.orderRepository)
    var orderRepository

    @Injected(\.geocodingService)
    var geocodingService

    init(popMe: (() -> Void)?) {
        self.popMe = popMe
    }

    func submitTapped() {
        orderRepository.address = .init(coordinate: orderCoordinate!.mapPointModel, details: orderDetails)
        popMe?()
    }

    func closeTapped() {
        popMe?()
    }

    func mapMoved(to coordinates: CLLocationCoordinate2D) {
        Task {
            self.finishAddress = try? await geocodingService.getAddress(for: coordinates)
            if let restaurantLocation = try? await orderRepository.checkRestaurantLocation(for: coordinates.mapPointModel) {
                restaurantCoordinate = restaurantLocation.coordinate.clLocationCoordinate2d
                restaurantAddress = restaurantLocation.details

                orderCoordinate = coordinates
                isSubmitEnabled = true
            }
        }
    }

    func addressFieldChanged(to value: String?) {
        orderDetails = value ?? ""
        Task {
            if let address = value,
               let coordinate = try? await geocodingService.getCoordinate(for: address) {
                if let orderCoordinate {
                    let orderLocation = CLLocation(latitude: orderCoordinate.latitude, longitude: orderCoordinate.longitude)
                    let detailLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    if orderLocation.distance(from: detailLocation) > 300 {
                        mapRegion = .init(center: coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                    }
                } else {
                    mapRegion = .init(center: coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                }
            }
        }
    }
}
