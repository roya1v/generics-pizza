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
        @Presents var newItem: NewMenuItemFeature.State?
        var menuState = MenuState.loaded([])
        var imageUrls = [MenuItem.ID: URL]()

        @CasePathable
        enum MenuState: Equatable {
            case loading
            case error(String)
            case loaded(IdentifiedArrayOf<MenuItem>)
        }
    }

    enum Action {
        case shown
        case loaded(Result<[MenuItem], Error>)
        case delete(MenuItem)
        case deleteConfirmationDialog(PresentationAction<DeleteConfirmationDialogAction>)
        case newItem(PresentationAction<NewMenuItemFeature.Action>)
        case newItemButtonTapped

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
                state.menuState = .loading
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await repository.fetchMenu() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                items.forEach { item in
                    state.imageUrls[item.id] = repository.imageUrl(for: item)
                }
                state.menuState = .loaded(IdentifiedArray(uniqueElements: items))
                return .none
            case .loaded(.failure(let error)):
                state.menuState = .error(error.localizedDescription)
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
            case .newItemButtonTapped:
                state.newItem = NewMenuItemFeature.State()
                return .none
            case .newItem(.presented(.cancelTapped)):
                state.newItem = nil
                return .none
            case .deleteConfirmationDialog:
                return .none
            case .newItem:
                return .none
            }
        }
        .ifLet(\.$deleteConfirmationDialog, action: \.deleteConfirmationDialog)
        .ifLet(\.$newItem, action: \.newItem) {
            NewMenuItemFeature()
        }
    }
}
