import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var menu = MenuFeature.State()
        var cart = [MenuItem]()
    }

    enum Action {
        case launched
        case menu(MenuFeature.Action)
    }

    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.orderRepository)
    private var orderRepository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .launched:
                return .none
            case .menu(.menuDetail(.presented(.addTapped))):
                if let item = state.menu.menuDetail?.item {
                    orderRepository.add(item: item)
                    state.cart.append(item)
                }
                return .none
            case .menu:
                return .none
            }
        }
        Scope(state: \.menu, action: \.menu) {
            MenuFeature()
        }
    }
}
