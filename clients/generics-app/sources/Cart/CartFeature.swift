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
        @Shared var items: [MenuItem]
        @Shared var destination: OrderType
        var subtotal = [SubtotalModel]()
    }

    enum Action {
        case appeared
        case dismissTapped
        case removeTapped(MenuItem)
        case placeOrder
        case estimateUpdated(Result<[SubtotalModel], Error>)
        case orderPlaced(Result<OrderModel, Error>)
    }

    @Injected(\.orderRepository)
    private var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .run { [state] send in
                    await send(
                        .estimateUpdated(
                            Result { try await repository.checkPrice(for: state.items, destination: state.destination) }
                        )
                    )
                }
            case .removeTapped:
                return .none
            case .placeOrder:
                return .run { [state] send in
                    await send(
                        .orderPlaced(
                            Result { try await repository.placeOrder(for: state.items, destination: state.destination) }
                        )
                    )
                }
            case .estimateUpdated(.success(let items)):
                state.subtotal = items
                return .none
            case .estimateUpdated(.failure(let error)):
                print(error)
                return .none
            case .orderPlaced(.success(let order)):
                return .none
            case .orderPlaced(.failure(let error)):
                print(error)
                return .none
            case .dismissTapped:
                return .none
            }
        }
    }
}
