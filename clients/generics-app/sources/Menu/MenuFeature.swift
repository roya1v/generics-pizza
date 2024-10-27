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
        var header = MenuHeaderFeature.State()
        var list = MenuListFeature.State()

        var contentState = ContentState.loading

        @Presents var menuDetail: MenuDetailFeature.State?

        enum ContentState {
            case loading
            case loaded
            case error
        }
    }

    enum Action {
        // View
        case appeared
        case refreshTapped

        // Child
        case header(MenuHeaderFeature.Action)
        case list(MenuListFeature.Action)
        case menuDetail(PresentationAction<MenuDetailFeature.Action>)
    }

    @Injected(\.menuRepository)
    private var menuRepository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                return .run { send in
                    await send(
                        .header(
                            .loaded(
                                Result { try await menuRepository.fetchCategories() }
                            )
                        )
                    )
                }
            case .list(.row(.element(let id, action: .rowAppeared))):
                state.list.items[id: id]?.isVisible = true
                return .none
            case .list(.row(.element(let id, action: .rowDisappeared))):
                state.list.items[id: id]?.isVisible = false
                return .none
            case .refreshTapped:
                state.contentState = .loading
                return .run { send in
                    await send(
                        .header(
                            .loaded(
                                Result { try await menuRepository.fetchCategories() }
                            )
                        )
                    )
                }
            case .list(.loaded(.success(let items))):
                state.list.items = IdentifiedArray(
                    uniqueElements: items
                        .sorted(by: { litem, ritem in
                            guard let lcategory = litem.category,
                                  let rcategory = ritem.category,
                                  let lindex = state.header.categories.firstIndex(of: lcategory),
                                  let rindex = state.header.categories.firstIndex(of: rcategory) else {
                                return false
                            }
                            return lindex < rindex
                        }) // TODO: Move this to the server
                        .map {
                            .init(
                                item: $0)
                        }
                )
                state.contentState = .loaded
                return .merge(
                    items.map { item in
                            .run { send in
                                await send(
                                    .list(.row(.element(
                                        id: item.id,
                                        action: .imageLoaded(
                                            Result {
                                                try await menuRepository.getImage(forItemId: item.id!)
                                            }
                                        )
                                    )
                                    )
                                         )
                                )
                            }
                    }
                )
            case .list(.loaded(.failure(let error))):
                state.contentState = .error
                return .none
            case .header(.loaded(.success(let categories))):
                state.header.categories = IdentifiedArray(uniqueElements: categories)
                state.header.selected = categories.first
                return .run { send in
                    await send(
                        .list(
                            .loaded(
                                Result { try await menuRepository.fetchMenu() }
                            )
                        )
                    )
                }
            case .header(.loaded(.failure(let error))):
                state.contentState = .error
                return .none
            case .list(.row(.element(let id, action: .rowTapped))):
                if let item = state.list.items[id: id] {
                    state.menuDetail = MenuDetailFeature.State(image: item.image, item: item.item)
                }
                return .none
            case .header(.categorySelected(let id)):
                state.list.scrolledTo = state.list.items.first(where: {$0.item.category?.id == id})
                state.header.selected = state.header.categories[id: id]
                return .none
            case .menuDetail(.presented(.dismissTapped)):
                state.menuDetail = .none
                return .none
            case .list(.row(.element(id: let id, action: .imageLoaded(.success(let image))))):
                state.list.items[id: id]?.image = image
                return .none
            case .header:
                return .none
            case .list:
                return .none
            case .menuDetail:
                return .none
            }
        }
    }
}
