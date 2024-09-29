import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import Combine
import MapKit

@Reducer
struct TrackingFeature {
    @ObservableState
    struct State: Equatable {
        let mapPins = [
            MapPin(id: UUID(), coordinate: restaurantCoordinates)
        ]
        var order: OrderModel
        var orderState: OrderModel.State?

        struct MapPin: Equatable, Identifiable {
            let id: UUID
            let coordinate: CLLocationCoordinate2D
        }
    }

    enum Action {
        case appeared
        case dismissTapped
        case trackingLoaded(Result<AnyPublisher<CustomerFromServerMessage, Error>, Error>)
        case newState(OrderModel.State)
    }

    @Injected(\.orderRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .run { [order = state.order]  send in
                    await send(
                        .trackingLoaded(
                            Result { try await repository.trackOrder(order)}
                        )
                    )
                }
            case .dismissTapped:
                return .none
            case .trackingLoaded(.success(let trackingPublisher)):
                return .publisher {
                    trackingPublisher
                        .compactMap { message in
                            switch message {
                            case .accepted:
                                return nil
                            case .newState(let state):
                                return .newState(state)
                            }
                        }
                        .catch { error in
                            Just(.trackingLoaded(.failure(error)))
                        }
                        .receive(on: DispatchQueue.main)
                        .eraseToAnyPublisher()
                }
            case .trackingLoaded(.failure(let error)):
                print(error)
                return .none
            case .newState(let orderState):
                state.orderState = orderState
                return .none
            }
        }
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == lhs.latitude
    }
}
