import ComposableArchitecture
import GenericsUI
import SwiftUI

struct MainHeaderView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        HStack {
            VStack {
                HStack {
                    Spacer()
                    Text("Generic's restaurant #1")
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gAccent)

                }
                destinationLabel
                    .font(.gCaption)
            }
            .onTapGesture {
                store.send(.showOrderDestination)
            }
            // This will be used later
            // Circle()
            //     .fill(Color.white)
            //     .frame(width: 40.0, height: 40.0)
        }
    }

    @ViewBuilder
    private var destinationLabel: some View {
        WithPerceptionTracking {
            switch store.destination {
            case .pickUp:
                Text("Self pick up")
            case .delivery(let address):
                Text("Delivery to \(address.street)")
            }
        }
    }
}
