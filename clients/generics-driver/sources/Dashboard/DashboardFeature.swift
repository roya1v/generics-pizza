import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory
import SharedModels
import Combine
import Foundation
import MapKit

@Reducer
struct DashboardFeature {

    @ObservableState
    struct State: Equatable {
        var mapRegion: MKCoordinateRegion = .init(
            center: restaurantCoordinates,
            span: .init(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )

        var restaurantPin = MapPin(coordinate: restaurantCoordinates, kind: .restaurant)

        // TODO: Change to stored property
        var clientPin: MapPin? {
            if let order,
               case let .delivery(address) = order.destination {
                return MapPin(coordinate: .init(latitude: address.coordinates.latitude, longitude: address.coordinates.longitude), kind: .client)

            } else {
                return nil
            }
        }

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
        case mapMoved(MKCoordinateRegion)

        // Child
        case detailsTile(DetailsTileFeature.Action)

        // Internal
        case newServerMessage(DriverFromServerMessage)
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
                state.mapRegion.center.latitude = address.coordinates.latitude
                state.mapRegion.center.longitude = address.coordinates.longitude
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
                return .none
            case .orderDelivered:
                state.detailsTile = .idle
                state.order = nil
                return .none
            case .receivedError(let error):
                print("Error happened \(error)")
                return .none
            case .mapMoved:
                return .none
            case .detailsTile:
                return .none
            }
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
