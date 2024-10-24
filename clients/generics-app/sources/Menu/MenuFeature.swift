import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels
import UIKit
import GenericsHelpers

@Reducer
struct MenuFeature {

    @ObservableState
    struct State: Equatable {
        var contentState = ContentState.loading
        var selectedCategory: MenuItem.Category?

        var categories = IdentifiedArrayOf<MenuItem.Category>()
        var items = IdentifiedArrayOf<Item>()

        @Presents var menuDetail: MenuDetailFeature.State?

        enum ContentState {
            case loading
            case loaded
            case error
        }

        struct Item: Equatable, Identifiable {
            var item: MenuItem
            var image: UIImage?

            var id: UUID? {
                item.id
            }
        }
    }

    enum Action {
        case appeared
        case refreshTapped
        case loaded(Result<[MenuItem], Error>)
        case loadedCategories(Result<[MenuItem.Category], Error>)
        case imageLoaded(id: UUID, result: Result<UIImage, Error>)
        case didSelect(UUID)
        case menuDetail(PresentationAction<MenuDetailFeature.Action>)
        case didSelectCategory(UUID)
    }

    @Injected(\.menuRepository)
    private var menuRepository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .run { send in
                    await send(
                        .loadedCategories(
                            Result { try await menuRepository.fetchCategories() }
                        )
                    )
                }
            case .refreshTapped:
                state.contentState = .loading
                return .run { send in
                    await send(
                        .loadedCategories(
                            Result { try await menuRepository.fetchCategories() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                state.items = IdentifiedArray(
                    uniqueElements: items.map {
                        State.Item(
                            item: $0)
                    }
                )
                state.contentState = .loaded
                return .merge(
                    items.map { item in
                            .run { send in
                                await send(
                                    .imageLoaded(
                                        id: item.id!,
                                        result: Result {
                                            try await menuRepository.getImage(forItemId: item.id!)
                                        }
                                    )
                                )
                            }
                    }
                )
            case .loaded(.failure(let error)):
                state.contentState = .error
                return .none
            case .loadedCategories(.success(let categories)):
                state.categories = IdentifiedArray(uniqueElements: categories)
                state.selectedCategory = categories.first
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await menuRepository.fetchMenu(category: categories.first!) }
                        )
                    )
                }
            case .loadedCategories(.failure(let error)):
                state.contentState = .error
                return .none
            case .didSelect(let id):
                if let item = state.items[id: id] {
                    state.menuDetail = MenuDetailFeature.State(image: item.image, item: item.item)
                }
                return .none
            case .didSelectCategory(let id):
                if let category = state.categories[id: id] {
                    state.selectedCategory = category
                    return .run { send in
                        await send(
                            .loaded(
                                Result { try await menuRepository.fetchMenu(category: category) }
                            )
                        )
                    }
                }
                return .none
            case .menuDetail(.presented(.dismissTapped)):
                state.menuDetail = .none
                return .none
            case .menuDetail:
                return .none
            case .imageLoaded(let id, result: .success(let image)):
                state.items[id: id]?.image = image
                return .none
            case .imageLoaded(let id, result: .failure(let error)):
                return .none

            }
        }
    }
}
