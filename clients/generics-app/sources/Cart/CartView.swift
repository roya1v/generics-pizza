import SwiftUI
import Factory
import GenericsCore
import GenericsUI
import SharedModels
import ComposableArchitecture

struct CartView: View {

    let store: StoreOf<CartFeature>

    var body: some View {
        WithPerceptionTracking {
            NavigationView {
                ZStack(alignment: .bottom) {
                    List {
                        Text("X items for Y$")
                            .font(.largeTitle)
                            .listRowSeparator(.hidden)
                        CartItemsView(store: store)
                        CartTotalView(store: store)
                    }
                    .listStyle(.plain)
                    Button {
                        store.send(.placeOrder)
                    } label: {
                        Text("Place order")
                            .frame(maxWidth: .infinity)
                            .frame(height: 32.0)
                    }
                    .buttonStyle(GPrimaryButtonStyle())
                    .padding()
                    .padding([.bottom])
                    .background(.thinMaterial)
                }

                .navigationTitle("Cart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            store.send(.dismissTapped)
                        } label: {
                            Text("Close")
                        }

                    }
                }
            }
            .task {
                store.send(.appeared)
            }
        }
    }
}
