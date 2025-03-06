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
                    header: .preview,
                    list: .preview,
                    contentState: .loaded,
                    menuDetail: nil),
                cart: Shared([]),
                destination: Shared(.pickUp))) {
                    EmptyReducer()
                }
    )
}
