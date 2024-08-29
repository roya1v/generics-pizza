import SwiftUI
import MapKit
import clients_libraries_GenericsUI
import ComposableArchitecture
import SharedModels

struct OrderDestinationView: View {

    @Perception.Bindable var store: StoreOf<OrderDestinationFeature>

    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .top) {
                Map(coordinateRegion: .constant(.init()))
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
                        selection: $store.destination) {
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
                VStack {
                    Text("Restaurant #1")
                    Button {
                        store.send(.confirm)
                    } label: {
                        Text("Order here")
                            .frame(maxWidth: .infinity)
                            .frame(height: 32.0)
                    }
                    .buttonStyle(GPrimaryButtonStyle())

                }
                .padding()
                .presentationDetents([.height(120.0)])
            }
        }
    }
}
