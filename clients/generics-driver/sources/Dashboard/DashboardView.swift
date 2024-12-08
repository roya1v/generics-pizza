import SwiftUI
import ComposableArchitecture
import MapKit

struct DashboardView: View {

    let store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            Map(
                coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: restaurantCoordinates,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.01,
                            longitudeDelta: 0.01
                        )
                    )
                )
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
            switch store.state {
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
