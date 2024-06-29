//
//  NewMenuItemFeature.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 28/06/2024.
//


import Foundation
import ComposableArchitecture
import SharedModels
import Factory

@Reducer
struct NewMenuItemFeature {
    @ObservableState
    struct State: Equatable {
        var title = ""
        var description = ""
        var price = 0.0
        var imageUrl: URL? = nil
        var isLoading = false
        var hasError = false
        var shouldDismiss = false
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case createTapped
        case imageSelected(URL)
        case createdNewItem(Error?)
    }
    
    @Injected(\.menuRepository)
    var repository
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
            case .imageSelected(let url):
                state.imageUrl = url
                return .none
            case .createTapped:
                let item = MenuItem(id: nil,
                                    title: state.title,
                                    description: state.description,
                                    price: Int(state.price * 100))
                let imageUrl = state.imageUrl
                state.isLoading = true
                return .run { [item, imageUrl] send in
                    do {
                        let menuItem = try await repository.create(item: item)
                        if let imageUrl {
                            try await repository.setImage(from: imageUrl, for: menuItem)
                        }
                        await send(.createdNewItem(nil))
                    } catch {
                        await send(.createdNewItem(error))
                    }
                    
                }
            case .createdNewItem(let error):
                if let error {
                    state.isLoading = false
                    state.hasError = true
                    return .none
                }
                state.shouldDismiss = true
                return .none
            }
        }
    }
}
