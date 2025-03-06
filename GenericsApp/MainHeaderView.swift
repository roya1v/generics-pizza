import ComposableArchitecture
import GenericsUI
import SwiftUI

struct MainHeaderView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        HStack {
            destinationIcon
            VStack(alignment: .leading) {
                HStack {
                    Text("Generic's restaurant #1")
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gAccent)

                }
                destinationLabel
                    .font(.gCaption)
                    .foregroundStyle(.gray)
            }
            .onTapGesture {
                store.send(.showOrderDestination)
            }
            Spacer()
            avatar
        }
        .padding(.horizontal, .gS)
    }

    @ViewBuilder
    private var destinationLabel: some View {
        switch store.destination {
        case .pickUp:
            Text("Self pick up")
        case .delivery(let address):
            Text("Delivery to \(address.street)")
        }
    }

    private var avatar: some View {
        ZStack {
            Circle()
                .fill(.gray.gradient)
            Image(systemName: "person.fill")
                .foregroundStyle(.white)
        }
        .frame(width: 40.0, height: 40.0)
    }

    private var destinationIcon: some View {
        ZStack {
            Circle()
                .fill(.gray.gradient)
            Image(systemName: "fork.knife")
                .foregroundStyle(.white)
        }
        .frame(width: 40.0, height: 40.0)
    }
}
