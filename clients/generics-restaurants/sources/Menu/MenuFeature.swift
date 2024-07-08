//
//  MenuFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 18/03/2024.
//

import Foundation
import ComposableArchitecture
import SharedModels
import Factory

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {
        var items: [MenuItem]
        var isLoading: Bool
        var imageUrls: [MenuItem.ID: URL]
    }

    enum Action {
        case shown
        case loaded([MenuItem])
        case delete(MenuItem.ID)
    }

    @Injected(\.menuRepository)
    var repository

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .shown:
                state.isLoading = true
                return .run { send in
                    let items = try! await repository.fetchMenu()
                    await send(.loaded(items))
                }
            case .loaded(let items):
                state.items = items
                items.forEach { item in
                    state.imageUrls[item.id] = repository.imageUrl(for: item)
                }
                state.isLoading = false
                return .none
            case .delete(_):
                return .none
            }
        }
    }
}
