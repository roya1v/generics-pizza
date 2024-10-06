import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

@Reducer
struct MenuItemFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        var item: MenuItem
        var image: ImageData?
        var isLoading = false

        var id: UUID? {
            item.id
        }
    }

    enum Action {
        case updateVisibility(Bool)
        case finishedLoading(Result<MenuItem, Error>)
        case imageLoaded(Result<ImageData, Error>)
        case deleteTapped
        case editTapped
    }

    @Injected(\.menuRepository)
    var repository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .updateVisibility(let newValue):
                state.isLoading = true
                let item = state.item
                let updatedItem = MenuItem(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    price: item.price,
                    isHidden: newValue
                )
                return .run { send in
                    await send(
                        .finishedLoading(
                            Result { try await repository.update(item: updatedItem) }
                        )

                    )
                }
            case .finishedLoading(.success(let newItem)):
                state.item = newItem
                state.isLoading = false
                return .none
            case .finishedLoading(.failure(let error)):
                state.isLoading = false
                return .none
            case .imageLoaded(.success(let image)):
                state.image = image
                return .none
            case .imageLoaded(.failure(let errror)):
                return .none
            case .deleteTapped:
                return .none
            case .editTapped:
                return .none
            }
        }
    }
}
