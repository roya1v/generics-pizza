import ComposableArchitecture
import AuthLogic
import GenericsCore
import Factory
import SharedModels
import Combine
import Foundation

@Reducer
struct DashboardFeature {
    @ObservableState
    enum State: Equatable {
        case idle
        case incommingOffer(OrderModel)
        case delivering(OrderModel)

        init() {
            self = .idle
        }
    }

    enum Action {
        // View
        case appeared
        case acceptOffer
        case orderDeliveredTapped

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
                state = .incommingOffer(order)
                return .none
            case .acceptOffer:
                guard case let .incommingOffer(order) = state else {
                    return .none
                }
                return .run { [order] send in
                    try await repository.send(.acceptOrder(order.id))
                    await send(.orderAccepted(order))
                }
            case .orderAccepted(let order):
                state = .delivering(order)
                return .none
            case .orderDeliveredTapped:
                guard case let .delivering(order) = state else {
                    return .none
                }

                return .run { [order] send in
                    try await repository.send(.delivered(order.id))
                    await send(.orderDelivered)
                }
            case .orderDelivered:
                state = .idle
                return .none
            case .receivedError(let error):
                print("Error happened \(error)")
                return .none
            }
        }
    }
}
