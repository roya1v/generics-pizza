import SwiftUI
import ComposableArchitecture
import MapKit

struct DashboardView: View {

    @Perception.Bindable
    var store: StoreOf<DashboardFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .bottom) {
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
                DetailsTile(store: store.scope(state: \.detailsTile, action: \.detailsTile))
                    .padding()
            }
        }
        .task {
            store.send(.appeared)
        }
    }
}
