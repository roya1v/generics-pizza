import ComposableArchitecture
import GenericsUI
import MapKit
import SharedModels
import SwiftUI

struct OrderDestinationView: View {

    @Bindable
    var store: StoreOf<OrderDestinationFeature>

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
                            .padding(.gXS)
                            .background(Circle().fill(Color.gAccent))
                    }
                    Picker(
                        "type",
                        selection: $store.picker.sending(\.pickerChanged).animation()
                    ) {
                        Text("Delivery")
                            .tag(OrderDestinationFeature.State.PickerThing.delivery)
                        Text("Restaurant")
                            .tag(OrderDestinationFeature.State.PickerThing.restaurant)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.gM)
            }
            .sheet(isPresented: .constant(true)) {
                form
                .padding()
                .presentationBackgroundInteraction(.enabled(upThrough: .height(240.0)))
                .interactiveDismissDisabled()
                .presentationDetents([.height(240.0)])
            }
            .task {
                store.send(.appeared)
            }
        }
    }

    @ViewBuilder
    var form: some View {
        WithPerceptionTracking {
            VStack {
                if let store = store.scope(state: \.deliveryForm, action: \.deliveryForm) {
                    DeliveryFormView(store: store)
                    Spacer()
                } else {
                    PickUpFormView()
                }
                Button {
                    store.send(.confirmTapped)
                } label: {
                    Text("Order here")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32.0)
                }
                .buttonStyle(GPrimaryButtonStyle(isWide: true))
            }
        }
    }
}
