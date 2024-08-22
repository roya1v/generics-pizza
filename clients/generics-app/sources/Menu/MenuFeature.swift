import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore

@Reducer
struct MenuFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var menuDetail: MenuDetailFeature.State?
        var content = SimpleListState<MenuItem>()
        // Temporary solution
        var imageUrls = [MenuItem.ID: URL]()
    }

    enum Action {
        case appeared
        case loaded(Result<[MenuItem], Error>)
        case didSelect(MenuItem)
        case menuDetail(PresentationAction<MenuDetailFeature.Action>)
    }

    @Injected(\.menuRepository)
    private var menuRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appeared:
                return .run { send in
                    await send(
                        .loaded(
                            Result { try await menuRepository.fetchMenu()}
                        )
                    )
                }
            case .loaded(.success(let items)):
                for item in items {
                    if let id = item.id {
                        state.imageUrls[id] = menuRepository.imageUrl(for: item )
                    }
                }
                state.content = .loaded(IdentifiedArray(uniqueElements: items))
                return .none
            case .loaded(.failure(let error)):
                return .none
            case .didSelect(let item):
                state.menuDetail = MenuDetailFeature.State(item: item)
                return .none
            case .menuDetail(.presented(.addTapped)):
                return .none
            case .menuDetail(.dismiss):
                state.menuDetail = .none
                return .none
            }
        }
    }
}
