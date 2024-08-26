import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        @Presents var cartState: CartFeature.State?
        var menu = MenuFeature.State()
        @Shared var cart: [MenuItem]
    }

    enum Action {
        case launched
        case showMenu
        case menu(MenuFeature.Action)
        case cart(PresentationAction<CartFeature.Action>)
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
                    state.cart.append(item)
                }
                state.menu.menuDetail = nil
                return .none
            case .showMenu:
                guard !state.cart.isEmpty else {
                    fatalError("Hello")
                }
                state.cartState = CartFeature.State(items: state.$cart)
                return .none
            case .menu:
                return .none
            case .cart(.presented(.dismissTapped)):
                state.cartState = nil
                return .none
            case .cart:
                return .none
            }
        }
        .ifLet(\.$cartState, action: \.cart) {
            CartFeature()
        }
        Scope(state: \.menu, action: \.menu) {
            MenuFeature()
        }
    }
}
