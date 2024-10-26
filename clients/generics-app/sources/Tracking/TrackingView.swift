import SwiftUI
import ComposableArchitecture
import SharedModels
import MapKit

struct TrackingView: View {

    let store: StoreOf<TrackingFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .topLeading) {
                map
                Button {
                    store.send(.dismissTapped)
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.white)
                        .padding(.gNormal)
                        .background(Circle().fill(Color.gAccent))
                }
                .padding()
            }
            .sheet(isPresented: .constant(true)) {
                VStack(alignment: .leading) {
                    title
                        .font(.largeTitle)
                    HStack {
                        ForEach([OrderModel.State.new,
                                 .inProgress,
                                 .readyForDelivery,
                                 .inDelivery,
                                 .finished],
                                id: \.rawValue) { state in
                            WithPerceptionTracking {
                                RoundedRectangle(cornerRadius: 3.0)
                                    .foregroundStyle(
                                        store.orderState == state
                                        ? Color.red
                                        : Color.gray
                                    )
                                    .frame(height: 4.0)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
                .presentationBackgroundInteraction(.enabled(upThrough: .height(120.0)))
                .interactiveDismissDisabled()
                .presentationDetents([.height(120.0)])
            }
            .task {
                store.send(.appeared)
            }
        }
    }

    var title: some View {
        WithPerceptionTracking {
            switch store.orderState {
            case .new:
                Text("Starting the order")
            case .inProgress:
                Text("In preparation")
            case .readyForDelivery:
                Text("Waiting for a driver")
            case .inDelivery:
                Text("In delivery")
            case .finished:
                Text("Delivered")
            default:
                Text("Loading")
            }
        }
    }

    var map: some View {
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
                ),
                annotationItems: store.mapPins
            ) { pin in
                MapMarker(coordinate: pin.coordinate)
            }
            .ignoresSafeArea()
        }
    }
}
