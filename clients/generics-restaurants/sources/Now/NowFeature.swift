//
//  NowFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 22/06/2024.
//

import Foundation
import ComposableArchitecture
import SharedModels
import Factory
import Combine

@Reducer
struct NowFeature {
    @ObservableState
    struct State: Equatable {
        var orders: [OrderModel] = []
        var isLoading = false
    }

    enum Action {
        case shown
        case connected(AnyPublisher<RestaurantFromServerMessage, any Error>)
        case newServerMessage(RestaurantFromServerMessage)
        case receivedError(Error)
        case update(orderId: UUID, state: OrderState)
        case updated(orderId: UUID, state: OrderState) // Find a better name for this?
    }

    @Injected(\.orderRestaurantRepository)
    private var repository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                state.isLoading = true
                return .run { send in
                    let publisher = try await repository.getFeed()
                    await send(.connected(publisher))
                }
            case .connected(let publisher):
                return .publisher {
                    publisher
                        .map { message in
                            .newServerMessage(message)
                        }
                        .catch { error in
                            Just(.receivedError(error))
                        }
                        .receive(on: DispatchQueue.main)
                }
            case .newServerMessage(let message):
                switch message {
                case .newOrder(let order):
                    state.orders.append(order)
                }
                return .none
            case .receivedError(_):
                return .none
            case .update(orderId: let orderId, state: let state):
                return .run { send in
                    try await repository.send(message: .update(orderId: orderId, state: state))
                    await send(.updated(orderId: orderId, state: state))
                }
            case .updated(orderId: let orderId, state: let orderState):
                if orderState == .finished {
                    state.orders = state.orders.filter { $0.id != orderId }
                    return .none
                }
                state.orders = state.orders.map { order in
                    if order.id == orderId {
                        return OrderModel(id: order.id,
                                          createdAt: order.createdAt,
                                          items: order.items,
                                          state: orderState,
                                          type: order.type)
                    }
                    return order
                }
                return .none
            }
        }
    }
}
