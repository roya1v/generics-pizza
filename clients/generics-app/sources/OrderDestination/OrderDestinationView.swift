import SwiftUI
import MapKit
import clients_libraries_GenericsUI

enum OrderDestination: Hashable {
    case restaurant, delivery
}

struct OrderDestinationView: View {

    @State var destination = OrderDestination.delivery

    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: .constant(.init()))
                .ignoresSafeArea()
            HStack {
                Button {

                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.white)
                        .padding(.gNormal)
                        .background(Circle().fill(Color.gAccent))
                }
                Picker(
                    "type",
                    selection: $destination) {
                        Text("Delivery")
                            .tag(OrderDestination.delivery)
                        Text("Restaurant")
                            .tag(OrderDestination.restaurant)
                    }
                    .pickerStyle(.segmented)
            }
            .padding(.gBig)
        }
        .sheet(isPresented: .constant(true), content: {
            VStack {
                TextField("Street and house number", text: .constant(""))
                    .textFieldStyle(.roundedBorder)

                HStack {
                    TextField("Entrance", text: .constant(""))
                        .textFieldStyle(.roundedBorder)

                    TextField("Intercome", text: .constant(""))
                        .textFieldStyle(.roundedBorder)

                }
                HStack {
                    TextField("Floor", text: .constant(""))
                        .textFieldStyle(.roundedBorder)

                    TextField("Appartment", text: .constant(""))
                        .textFieldStyle(.roundedBorder)

                }
                TextField("Comment", text: .constant(""))
                    .textFieldStyle(.roundedBorder)
                Button {
                } label: {
                    Text("Order here")
                        .frame(maxWidth: .infinity)
                        .frame(height: 32.0)
                }
                .buttonStyle(GPrimaryButtonStyle())

            }
                .presentationDetents([.fraction(1.0 / 3.0)])
        })
    }
}

#Preview {
    OrderDestinationView()
}
