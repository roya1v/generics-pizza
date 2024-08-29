import Foundation
import ComposableArchitecture
import Factory
import SharedModels
import clients_libraries_GenericsCore

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var currentOrder: OrderModel?
        @Presents var cartState: CartFeature.State?
        @Presents var trackingState: TrackingFeature.State?
        var menu = MenuFeature.State()
        @Shared var cart: [MenuItem]
    }

    enum Action {
        case launched
        case showMenu
        case menu(MenuFeature.Action)
        case cart(PresentationAction<CartFeature.Action>)
        case tracking(PresentationAction<TrackingFeature.Action>)
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
            case .cart(.presented(.orderPlaced(.success(let order)))):
                state.cart = []
                state.cartState = nil
                state.currentOrder = order
                state.trackingState = TrackingFeature.State(order: order)
                return .none
            case .cart(.presented(.dismissTapped)):
                state.cartState = nil
                return .none
            case .cart:
                return .none
            case .tracking(.presented(.newState(.finished))):
                state.currentOrder = nil
                return .none
            case .tracking:
                return .none
            }
        }
        .ifLet(\.$cartState, action: \.cart) {
            CartFeature()
        }
        .ifLet(\.$trackingState, action: \.tracking) {
            TrackingFeature()
        }
        Scope(state: \.menu, action: \.menu) {
            MenuFeature()
        }
    }
}
