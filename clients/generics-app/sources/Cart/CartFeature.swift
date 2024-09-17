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
        @Shared var items: IdentifiedArrayOf<CartItemFeature.State>
        @Shared var destination: OrderModel.Destination
        var subtotal = [SubtotalModel]()
    }

    enum Action {
        case appeared
        case dismissTapped
        case placeOrder
        case estimateUpdated(Result<[SubtotalModel], Error>)
        case orderPlaced(Result<OrderModel, Error>)
        case item(IdentifiedActionOf<CartItemFeature>)
    }

    @Injected(\.orderRepository)
    private var repository

    @Dependency(\.dismiss)
    private var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .run { [state] send in
                    await send(
                        .estimateUpdated(
                            Result { try await repository.checkPrice(for: state.items.map { OrderModel.Item(menuItem: $0.menuItem, count: $0.count)}, destination: state.destination) }
                        )
                    )
                }
            case .item(.element(id: let id, action: .increaseTapped)):
                state.items[id: id]?.count += 1
                return .none
            case .item(.element(id: let id, action: .decreaseTapped)):
                guard let item = state.items[id: id] else {
                    return .none
                }
                if item.count == 1 {
                    state.items.remove(item)
                    if state.items.isEmpty {
                        return .run { _ in
                            await dismiss()
                        }
                    }
                } else {
                    state.items[id: id]?.count -= 1
                }
                return .none
            case .item:
                return .none
            case .placeOrder:
                return .run { [state] send in
                    await send(
                        .orderPlaced(
                            Result { try await repository.placeOrder(for: state.items.map { OrderModel.Item(menuItem: $0.menuItem, count: $0.count)}, destination: state.destination) }
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
