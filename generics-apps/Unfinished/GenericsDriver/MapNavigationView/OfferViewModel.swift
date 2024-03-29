//
//  OfferViewModel.swift
//  GenericsDriver
//
//  Created by Mike S. on 20/09/2023.
//

import Foundation
import Factory
import MapKit
import SharedModels

final class OfferViewModel: ObservableObject {

    @Published private(set) var routeToRestaurant: MKPolyline?
    @Published private(set) var routeToClient: MKPolyline?

    @Injected(\.routingService)
    private var routingService

    @Injected(\.mainStateHolder)
    private var mainStateHolder

    @Injected(\.locationRepository)
    private var locationRepository

    init(restaurantAddress: AddressModel,
         customerAddress: AddressModel,
         reward: Int) {
        Task {
            let myLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            routeToRestaurant = try? await routingService.getRoute(from: myLocation,
                                                                   to: restaurantAddress.coordinate.clLocationCoordinate2d)

        }
        Task {
            routeToClient = try? await routingService.getRoute(from: restaurantAddress.coordinate.clLocationCoordinate2d,
                                                               to: customerAddress.coordinate.clLocationCoordinate2d)

        }
    }

    func acceptOffer() {
        Task {
            try? await mainStateHolder.acceptOffer()
        }
    }

    func declineOffer() {
        Task {
            try? await mainStateHolder.acceptOffer()
        }
    }
}
