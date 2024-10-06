import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels
import GenericsHelpers

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var deleteConfirmationDialog:
            ConfirmationDialogState<Action.DeleteConfirmationDialogAction>?
        @Presents var itemForm: MenuItemFormFeature.State?
        var menuState = SimpleListState<MenuItemFeature.State>()
    }

    enum Action {
        case shown
        case loaded(Result<[MenuItem], Error>)
        case deleteConfirmationDialog(PresentationAction<DeleteConfirmationDialogAction>)
        case deletionCompleted(id: MenuItemFeature.State.ID, result: Result<Void, Error>)
        case itemForm(PresentationAction<MenuItemFormFeature.Action>)
        case newItemButtonTapped
        case item(IdentifiedActionOf<MenuItemFeature>)

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
                            Result { try await repository.fetchMenu(showHidden: true) }
                        )
                    )
                }
            case .loaded(.success(let items)):
                state.menuState = .loaded(
                    IdentifiedArray(
                        uniqueElements: items.map { MenuItemFeature.State(item: $0) }
                    )
                )
                return .merge(items.map { loadImage(for: $0) })
            case .loaded(.failure(let error)):
                state.menuState = .error(error.localizedDescription)
                return .none
            case .item(.element(id: let id, action: .deleteTapped)):
                let item = state.menuState.items[id: id]!.item
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
            case .item(.element(id: let id, action: .editTapped)):
                state.itemForm = MenuItemFormFeature.State(
                    menuItem: state.menuState.items[id: id]!.item)
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
            case .deletionCompleted(let id, result: .success):
                state.menuState.items.remove(id: id)
                return .none
            case .deletionCompleted(let id, result: .failure(let error)):
                print("Error: \(error) for id: \(String(describing: id))")
                return .none
            case .item:
                return .none
            case .newItemButtonTapped:
                state.itemForm = MenuItemFormFeature.State()
                return .none
            case .itemForm(.presented(.cancelTapped)):
                state.itemForm = nil
                return .none
            case .itemForm(.presented(.createdNewItem(.success(let newItem)))):
                state.itemForm = nil
                if state.menuState.items[id: newItem.id] != nil {
                    state.menuState.items[id: newItem.id]?.item = newItem
                    return loadImage(for: newItem)
                } else {
                    state.menuState.items.append(MenuItemFeature.State(item: newItem))
                    return loadImage(for: newItem)
                }
            case .itemForm:
                return .none
            case .deleteConfirmationDialog:
                return .none
            }
        }
        .ifLet(\.$deleteConfirmationDialog, action: \.deleteConfirmationDialog)
        .ifLet(\.$itemForm, action: \.itemForm) {
            MenuItemFormFeature()
        }
        .forEach(\.menuState.items, action: \.item) {
            MenuItemFeature()
        }
    }

    func loadImage(for item: MenuItem) -> Effect<Action> {
        .run { send in
            await send(
                .item(
                    .element(
                        id: item.id,
                        action: .imageLoaded(
                            Result { try await repository.getImage(forItemId: item.id!) }
                        )
                    )
                )
            )
        }
    }
}
