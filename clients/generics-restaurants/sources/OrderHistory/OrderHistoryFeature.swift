//
//  OrderHistoryFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 18/03/2024.
//

import Foundation
import ComposableArchitecture
import SharedModels
import Factory

@Reducer
struct OrderHistoryFeature {
    @ObservableState
    struct State: Equatable {
        var items = IdentifiedArrayOf<OrderModel>()
    }

    enum Action {
        case shown
        case loaded(Result<[OrderModel], Error>)
    }

    @Injected(\.orderRestaurantRepository)
    var repository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await repository.getHistory() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                state.items = IdentifiedArray(uniqueElements: items)
                return .none
            case .loaded(.failure):
                // TODO: Implement proper error handling
                print("Implement proper error handling!")
                return .none
            }
        }
    }
}
