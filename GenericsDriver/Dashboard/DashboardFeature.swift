import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory
import SharedModels
import Combine
import Foundation
import MapKit
import SwiftUI
import CoreLocation

@Reducer
struct DashboardFeature {

    @ObservableState
    struct State: Equatable {
        @Presents var profile: ProfileFeature.State?

        var mapPosition = MapCameraPosition.region(
            MKCoordinateRegion(center: .restaurant, latitudinalMeters: 0.1, longitudinalMeters: 0.1)
        )

        var restaurant: CLLocationCoordinate2D = .restaurant
        var client: CLLocationCoordinate2D?
        var route: MKRoute?

        var detailsTile = DetailsTileFeature.State.idle
        var order: OrderModel?

        struct MapPin: Equatable, Identifiable {
            let coordinate: CLLocationCoordinate2D
            let kind: Kind

            var id: Kind {
                kind
            }

            enum Kind {
                case restaurant, client
            }
        }
    }

    enum Action {
        // View
        case appeared
        case mapMoved(MapCameraPosition)
        case profileTapped

        // Child
        case detailsTile(DetailsTileFeature.Action)
        case profile(PresentationAction<ProfileFeature.Action>)

        // Internal
        case newServerMessage(DriverFromServerMessage)
        case routeLoaded(MKRoute)
        case orderAccepted(OrderModel)
        case orderDelivered
        case receivedError(Error)
    }

    @Injected(\.driverRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .publisher {
                    repository.getFeed()
                        .map { message in
                                .newServerMessage(message)
                        }
                        .catch { error in
                            Just(.receivedError(error))
                        }
                        .receive(on: DispatchQueue.main)
                }
            case .newServerMessage(.offerOrder(let order)):
                guard case let .delivery(address) = order.destination else {
                    return .none
                }
                // TODO: Fix
//                state.mapPosition.camera?.centerCoordinate.latitude = address.coordinates.latitude
//                state.mapPosition.camera?.centerCoordinate.longitude = address.coordinates.longitude
                state.detailsTile = .offerOrder(details: "\(address)")
                state.order = order
                return .none
            case .detailsTile(.buttonTapped):
                guard let order = state.order else {
                    fatalError("You can't tap any buttons without an order!")
                }
                switch state.detailsTile {
                case .idle:
                    fatalError("You can't tap any buttons when idle!")
                case .offerOrder:
                    return .run { [order] send in
                        try await repository.send(.acceptOrder(order.id))
                        await send(.orderAccepted(order))
                    }
                case .delivering:
                    return .run { [order] send in
                        try await repository.send(.delivered(order.id))
                        await send(.orderDelivered)
                    }
                }
                return .none
            case .orderAccepted(let order):
                guard case let .delivery(address) = order.destination else {
                    return .none
                }
                state.detailsTile = .delivering(details: "\(address)")
                // TODO: Fix
//                state.clientPin = State.MapPin(
//                    coordinate: .init(
//                        latitude: address.coordinates.latitude,
//                        longitude: address.coordinates.longitude),
//                    kind: .client
//                )
                return .none
            case .orderDelivered:
                state.detailsTile = .idle
                state.order = nil
                return .none
            case .receivedError(let error):
                print("Error happened \(error)")
                return .none
            case .profileTapped:
                state.profile = ProfileFeature.State()
                return .none
            case .routeLoaded(_):
                return .none
            case .mapMoved:
                return .none
            case .detailsTile:
                return .none
            case .profile:
                return .none
            }
        }
        .ifLet(\.$profile, action: \.profile) {
            ProfileFeature()
        }
    }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }
}

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan:  @retroactive Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.longitudeDelta == rhs.longitudeDelta && lhs.latitudeDelta == rhs.latitudeDelta
    }
}
