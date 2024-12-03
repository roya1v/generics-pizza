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
        case incommingOffer(OrderModel.ID)
        case delivering(OrderModel.ID)

        init() {
            self = .idle
        }
    }

    enum Action {
        case appeared
        case acceptOffer
        case orderDelivered

        case newServerMessage(DriverFromServerMessage)
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
                state = .incommingOffer(order.id)
                return .none
            case .acceptOffer:
                guard case let .incommingOffer(id) = state else {
                    return .none
                }
                state = .delivering(id)
                return .run { [id] send in
                    try await repository.send(.acceptOrder(id))
                }
            case .orderDelivered:
                guard case let .delivering(id) = state else {
                    return .none
                }
                state = .idle
                return .run { [id] send in
                    try await repository.send(.delivered(id))
                }
            case .receivedError(let error):
                print("Error happened \(error)")
                return .none
            }
        }
    }
}
