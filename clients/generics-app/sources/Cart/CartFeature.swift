import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore
import Combine

@Reducer
struct CartFeature {
    @ObservableState
    struct State: Equatable {
        enum SubState: Equatable {
            case needItems
            case readyForOrder
            case loadingOrderDetails
            case loading
            case inOrderState(state: OrderState)
            case error
        }
        @Shared var items: [MenuItem]
        var subtotal = [SubtotalModel]()
        var subState = SubState.readyForOrder
    }

    enum Action {
        case appeared
        case dismissTapped
        case removeTapped(MenuItem)
        case placeOrder
        case estimateUpdated(Result<[SubtotalModel], Error>)
        case orderPlaced(Result<AnyPublisher<CustomerFromServerMessage, Error>, Error>)
        case newServerMessage(CustomerFromServerMessage)
    }

    @Injected(\.orderRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                state.subState = .loadingOrderDetails
                return .run { send in
                    await send(
                        .estimateUpdated(
                            Result { try await repository.checkPrice(for: []) }
                        )
                    )
                }
            case .removeTapped:
                return .none
            case .placeOrder:
                return .run { send in
                    await send(
                        .orderPlaced(
                            Result { try await repository.placeOrder(for: []) }
                        )
                    )
                }
            case .estimateUpdated(.success(let items)):
                state.subtotal = items
                state.subState = .readyForOrder
                return .none
            case .estimateUpdated(.failure(let error)):
                print(error)
                return .none
            case .orderPlaced(.success(let publisher)):
                return .publisher {
                    publisher
                        .map { message in
                            .newServerMessage(message)
                        }
                        .catch { error in
                            Just(.orderPlaced(.failure(error)))
                        }
                        .receive(on: DispatchQueue.main)
                }
            case .orderPlaced(.failure(let error)):
                print(error)
                return .none
            case .newServerMessage(let message):
                switch message {
                case .accepted:
                    fatalError()
                case .newState(let orderState):
                    state.subState = .inOrderState(state: orderState)
                }
                return .none
            case .dismissTapped:
                return .none
            }
        }
    }
}
