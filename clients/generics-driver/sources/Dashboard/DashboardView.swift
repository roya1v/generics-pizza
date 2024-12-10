import SwiftUI
import ComposableArchitecture
import MapKit

struct DashboardView: View {

    @Perception.Bindable
    var store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            Map(
                coordinateRegion: $store.mapRegion.sending(\.mapMoved),
                annotationItems: [store.restaurantPin, store.clientPin].compactMap(\.self)
            ) { pin in
                switch pin.kind {
                case .client:
                    MapMarker(coordinate: pin.coordinate, tint: .black)
                case .restaurant:
                    MapMarker(coordinate: pin.coordinate, tint: .green)
                }
            }
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
