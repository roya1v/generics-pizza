import ComposableArchitecture
import SharedModels
import GenericsUI
import SwiftUI

struct ContentView: View {

    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationView {
                ZStack {
                    Color.gLight
                        .ignoresSafeArea()
                    VStack {
                        MainHeaderView(store: store)
                            .padding()
                        MenuView(
                            store: store.scope(
                                state: \.menu,
                                action: \.menu
                            )
                        )
                    }
                }
            }

            if !store.cart.isEmpty {
                Button {
                    store.send(.showMenu)
                } label: {
                    HStack {
                        Text("Cart")
                        Image(systemName: "cart")
                    }
                    .padding(.gXS)
                }
                .buttonStyle(GPrimaryButtonStyle())
                .padding()
            }
            if store.currentOrder != nil {
                Button {
                    store.send(.showOrderTrackingTapped)
                } label: {
                    HStack {
                        Text("Track order")
                        Image(systemName: "cart")
                    }
                    .padding(.gXS)
                }
                .buttonStyle(GPrimaryButtonStyle())
                .padding()
            }
        }
        .task {
            store.send(.launched)
        }
        .sheet(
            item: $store.scope(
                state: \.cartState,
                action: \.cart
            )
        ) { store in
            CartView(store: store)
        }
        .sheet(
            item: $store.scope(
                state: \.trackingState,
                action: \.tracking
            )
        ) { store in
            TrackingView(store: store)
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.orderDestination,
                action: \.orderDestination
            )
        ) { store in
            OrderDestinationView(store: store)
        }
    }
}

#Preview {
    ContentView(
        store: Store(
            initialState: AppFeature.State(
                currentOrder: nil,
                cartState: nil,
                trackingState: nil,
                orderDestination: nil,
                menu: MenuFeature.State(
                    header: MenuHeaderFeature.State(
                        categories: [
                            MenuItem.Category(
                                id: nil,
                                name: "Pizza"
                            )
                        ],
                        selected: MenuItem.Category(
                            id: nil,
                            name: "Pizza"
                        )
                    ),
                    list: MenuListFeature.State(
                        items: [
                            MenuRowFeature.State(
                                item: MenuItem(
                                    id: UUID(),
                                    title: "Test",
                                    description: "Test",
                                    price: 999,
                                    isHidden: false,
                                    category: nil
                                ),
                                image: nil,
                                isVisible: true
                            )
                        ],
                        scrolledTo: nil
                    ),
                    contentState: .loaded,
                    menuDetail: nil),
                cart: Shared([]),
                destination: Shared(.pickUp))) {
                    EmptyReducer()
                }
    )
}
