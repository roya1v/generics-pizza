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
        @Presents var menuDetail: MenuDetailFeature.State?
        var content = SimpleListState<Item>()

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
        case loaded(Result<[MenuItem], Error>)
        case imageLoaded(id: UUID, result: Result<UIImage, Error>)
        case didSelect(UUID)
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
                        .loaded(
                            Result { try await menuRepository.fetchMenu() }
                        )
                    )
                }
            case .loaded(.success(let items)):
                state.content = .loaded(
                    IdentifiedArray(
                        uniqueElements: items.map {
                            State.Item(
                                item: $0)
                        }
                    )
                )
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
                return .none
            case .didSelect(let id):
                if let item = state.content.items[id: id] {
                    state.menuDetail = MenuDetailFeature.State(image: item.image, item: item.item)
                }
                return .none
            case .menuDetail(.presented(.dismissTapped)):
                state.menuDetail = .none
                return .none
            case .menuDetail:
                return .none
            case .imageLoaded(let id, result: .success(let image)):
                state.content.items[id: id]?.image = image
                return .none
            case .imageLoaded(let id, result: .failure(let error)):
                return .none
            }
        }
    }
}
