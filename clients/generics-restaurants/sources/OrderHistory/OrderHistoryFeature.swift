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
        case loaded([OrderModel])
    }

    @Injected(\.orderRestaurantRepository)
    var repository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                return .run { send in
                    let items = try! await repository.getHistory()
                    await send(.loaded(items))
                }
            case .loaded(let items):
                state.items = IdentifiedArray(uniqueElements: items)
                return .none
            }
        }
    }
}
