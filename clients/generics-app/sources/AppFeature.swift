import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var currentOrder: OrderModel?
        @Presents var cartState: CartFeature.State?
        @Presents var trackingState: TrackingFeature.State?
        @Presents var orderDestination: OrderDestinationFeature.State?
        var menu = MenuFeature.State()
        @Shared var cart: IdentifiedArrayOf<CartItemFeature.State>
        @Shared var destination: OrderModel.Destination
    }

    enum Action {
        case launched
        case showMenu
        case showOrderTrackingTapped
        case showOrderDestination
        case menu(MenuFeature.Action)
        case cart(PresentationAction<CartFeature.Action>)
        case tracking(PresentationAction<TrackingFeature.Action>)
        case orderDestination(PresentationAction<OrderDestinationFeature.Action>)
    }

    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.orderRepository)
    private var orderRepository

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .launched:
                return .none
            case .menu(.menuDetail(.presented(.addTapped))):
                if let item = state.menu.menuDetail?.item {
                    state.cart.append(.init(menuItem: item, count: 1))
                }
                state.menu.menuDetail = nil
                return .none
            case .showMenu:
                guard !state.cart.isEmpty else {
                    fatalError("Hello")
                }
                state.cartState = CartFeature.State(
                    items: state.$cart,
                    destination: state.$destination)
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
            case .showOrderTrackingTapped:
                guard let order = state.currentOrder else {
                    return .none
                }
                state.trackingState = TrackingFeature.State(order: order)
                return .none
            case .tracking(.presented(.dismissTapped)):
                state.trackingState = nil
                return .none
            case .tracking(.presented(.newState(.finished))):
                state.currentOrder = nil
                return .none
            case .tracking:
                return .none
            case .orderDestination(.presented(.dismissTapped)),
                    .orderDestination(.presented(.confirmTapped)):
                state.orderDestination = nil
                return .none
            case .orderDestination:
                return .none
            case .showOrderDestination:
                state.orderDestination = OrderDestinationFeature.State(
                    destination: state.$destination
                )
                return .none
            }
        }
        .ifLet(\.$cartState, action: \.cart) {
            CartFeature()
        }
        .ifLet(\.$trackingState, action: \.tracking) {
            TrackingFeature()
        }
        .ifLet(\.$orderDestination, action: \.orderDestination) {
            OrderDestinationFeature()
        }
        Scope(state: \.menu, action: \.menu) {
            MenuFeature()
        }
    }
}
