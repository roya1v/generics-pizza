import SwiftUI
import ComposableArchitecture
import MapKit

struct DashboardView: View {

    @Perception.Bindable
    var store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            Map(
                coordinateRegion: $store.mapRegion.sending(\.mapMoved)
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: .constant(true)) {
            sheetContent
                .padding()
                .presentationBackgroundInteraction(.enabled(upThrough: .height(120.0)))
                .interactiveDismissDisabled()
                .presentationDetents([.height(120.0)])
        }
        .task {
            store.send(.appeared)
        }
    }

    @ViewBuilder
    var sheetContent: some View {
        WithPerceptionTracking {
            switch store.state.order {
            case .idle:
                Text("Waiting for an order")
            case .incommingOffer:
                Button("Accept offer") {
                    store.send(.acceptOffer)
                }
            case .delivering:
                Button("Delivery complete") {
                    store.send(.orderDeliveredTapped)
                }
            }
        }
    }
}
