import SwiftUI
import ComposableArchitecture

struct DashboardView: View {

    let store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            switch store.state {
            case .idle:
                Text("Waiting for an order")
            case .incommingOffer:
                Button("Accept offer") {
                    store.send(.acceptOffer)
                }
            case .delivering:
                Button("Delivery complete") {
                    store.send(.orderDelivered)
                }
            }
        }
        .task {
            store.send(.appeared)
        }
    }
}
