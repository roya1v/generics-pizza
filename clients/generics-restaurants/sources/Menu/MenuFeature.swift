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
import clients_libraries_GenericsCore

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var deleteConfirmationDialog: ConfirmationDialogState<Action.DeleteConfirmationDialogAction>?
        @Presents var newItem: NewMenuItemFeature.State?
        var menuState = SimpleListState<Item>()

        struct Item: Equatable, Identifiable {
            var item: MenuItem
            var image: ImageData?

            var id: UUID? {
                item.id
            }
        }
    }

    enum Action {
        case shown
        case loaded(Result<[MenuItem], Error>)
        case delete(MenuItem)
        case deleteConfirmationDialog(PresentationAction<DeleteConfirmationDialogAction>)
        case deletionCompleted(id: State.Item.ID, result: Result<Void, Error>)
        case imageLoaded(id: State.Item.ID, result: Result<ImageData, Error>)
        case newItem(PresentationAction<NewMenuItemFeature.Action>)
        case newItemButtonTapped

        @CasePathable
        enum DeleteConfirmationDialogAction: Equatable {
            case delete(MenuItem)
        }
    }

    @Injected(\.menuRepository)
    var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
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
                state.menuState = .loaded(IdentifiedArray(uniqueElements: items.map { State.Item(item: $0)}))
                return .merge(
                    items.map { item in
                            .run { send in
                                await send(
                                    .imageLoaded(
                                        id: item.id,
                                        result: Result { try await repository.getImage(forItemId: item.id!) }
                                    )
                                )
                            }
                    }
                )
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
                return .run { send in
                    await send(
                        .deletionCompleted(
                            id: item.id,
                            result: Result { try await repository.delete(item: item) }
                        ),
                        animation: .default)
                }
            case .deletionCompleted(id: let id, result: .success):
                state.menuState.items?.remove(id: id)
                return .none
            case .deletionCompleted(id: let id, result: .failure(let error)):
                print("Error: \(error) for id: \(String(describing: id))")
                return .none
            case .newItemButtonTapped:
                state.newItem = NewMenuItemFeature.State()
                return .none
            case .newItem(.presented(.cancelTapped)):
                state.newItem = nil
                return .none
            case .imageLoaded(id: let id, result: .success(let image)):
                state.menuState.items?[id: id]?.image = image
                return .none
            case .imageLoaded(id: let id, result: .failure(let error)):
                print("Error: \(error) for id: \(String(describing: id))")
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
