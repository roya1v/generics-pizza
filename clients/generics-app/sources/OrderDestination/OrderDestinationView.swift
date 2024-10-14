import ComposableArchitecture
import GenericsUI
import MapKit
import SharedModels
import SwiftUI

struct OrderDestinationView: View {

    @Perception.Bindable var store: StoreOf<OrderDestinationFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .top) {
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
                HStack {
                    Button {
                        store.send(.dismissTapped)
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.white)
                            .padding(.gNormal)
                            .background(Circle().fill(Color.gAccent))
                    }
                    Picker(
                        "type",
                        selection: $store.destination
                    ) {
                        Text("Delivery")
                            .tag(OrderDestinationFeature.State.Destination.delivery)
                        Text("Restaurant")
                            .tag(OrderDestinationFeature.State.Destination.restaurant)
                    }
                    .pickerStyle(.segmented)
                    .disabled(true)
                }
                .padding(.gBig)
            }
            .sheet(isPresented: .constant(true)) {
                PickUpFormView(store: store)
                .padding()
                .presentationBackgroundInteraction(.enabled(upThrough: .height(120.0)))
                .interactiveDismissDisabled()
                .presentationDetents([.height(120.0)])
            }
        }
    }
}
