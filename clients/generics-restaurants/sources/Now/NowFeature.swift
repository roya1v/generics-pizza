import Foundation
import ComposableArchitecture
import SharedModels
import Factory
import Combine

@Reducer
struct NowFeature {
    @ObservableState
    struct State: Equatable {
        var orders = IdentifiedArrayOf<OrderModel>()
        var connectionState = ConnectionState.connecting

        enum ConnectionState: Equatable {
            case connecting
            case success
            case failure(String)
        }
    }

    enum Action {
        case shown
        case newServerMessage(RestaurantFromServerMessage)
        case receivedError(Error)
        case update(orderId: UUID, state: OrderModel.State)
        case updateCompleted(orderId: UUID, state: OrderModel.State)
    }

    enum CancelId: Hashable { case messages }

    @Injected(\.orderRestaurantRepository)
    private var repository

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .shown:
                if state.connectionState == .success {
                    return .none
                }
                state.connectionState = .connecting
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
                .cancellable(id: CancelId.messages)
            case .newServerMessage(let message):
                if state.connectionState != .success {
                    state.connectionState = .success
                }
                switch message {
                case .newOrder(let order):
                    state.orders.append(order)
                }
                return .none
            case .receivedError(let error):
                state.connectionState = .failure(error.localizedDescription)
                return .cancel(id: CancelId.messages)
            case .update(orderId: let orderId, state: let state):
                return .run { send in
                    try await repository.send(message: .update(orderId: orderId, state: state))
                    await send(.updateCompleted(orderId: orderId, state: state))
                }
            case .updateCompleted(orderId: let orderId, state: let orderState):
                if orderState == .finished {
                    state.orders.remove(id: orderId)
                    return .none
                }
                if let existing = state.orders[id: orderId] {
                    state.orders[id: orderId] = OrderModel(
                        id: existing.id,
                        createdAt: existing.createdAt,
                        items: existing.items,
                        state: orderState,
                        destination: existing.destination
                    )
                }
                return .none
            }
        }
    }
}
