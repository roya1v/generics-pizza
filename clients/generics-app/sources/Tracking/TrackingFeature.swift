import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import Combine

@Reducer
struct TrackingFeature {
    @ObservableState
    struct State: Equatable {
        var order: OrderModel
        var orderState: OrderState?
    }

    enum Action {
        case appeared
        case dismissTapped
        case trackingLoaded(Result<AnyPublisher<CustomerFromServerMessage, Error>, Error>)
        case newState(OrderState)
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
