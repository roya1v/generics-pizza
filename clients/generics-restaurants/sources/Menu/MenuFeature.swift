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
        @Presents var deleteConfirmationDialog: ConfirmationDialogState<Action.DeleteConfirmationDialogAction>?
        var items = IdentifiedArrayOf<MenuItem>()
        var isLoading = false
        var imageUrls = [MenuItem.ID: URL]()
    }

    enum Action {
        case shown
        case loaded([MenuItem])
        case delete(MenuItem)
        case deleteConfirmationDialog(PresentationAction<DeleteConfirmationDialogAction>)
        
        @CasePathable
        enum DeleteConfirmationDialogAction: Equatable {
            case delete(MenuItem)
        }
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
                state.items = IdentifiedArray(uniqueElements: items)
                items.forEach { item in
                    state.imageUrls[item.id] = repository.imageUrl(for: item)
                }
                state.isLoading = false
                return .none
            case .delete(let item):
                state.deleteConfirmationDialog = ConfirmationDialogState {
                    TextState("Are you sure?")
                } actions: {
                    ButtonState(role: .cancel) {
                        TextState("Cancel")
                    }
                    ButtonState(action: .delete(item)) {
                        TextState("Delete")
                    }
                }
                return .none
            case .deleteConfirmationDialog(.presented(.delete(let item))):
                return .none
            case .deleteConfirmationDialog(_):
                return .none
            }
        }
        .ifLet(\.$deleteConfirmationDialog, action: \.deleteConfirmationDialog)
    }
}
