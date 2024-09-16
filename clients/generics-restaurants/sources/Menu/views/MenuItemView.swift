import SwiftUI
import ComposableArchitecture

struct MenuItemView: View {

    let store: StoreOf<MenuItemFeature>

    var body: some View {
        WithPerceptionTracking {
            HStack {
                if let image = store.image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75.0)
                } else {
                    Image("pizzza_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75.0)
                }
                VStack(alignment: .leading) {
                    Text(store.item.title)
                        .font(.title2)
                    Text(store.item.description)
                        .font(.caption)
                }
                Spacer()
                Text(store.item.formattedPrice())
                    .bold()
                    .padding()
                if store.isLoading {
                    ProgressView()
                }
                Toggle(
                    isOn: Binding(
                        get: { store.item.isHidden },
                        set: { store.send(.updateVisibility($0)) }
                    )
                ) {
                    Text("Is Hidden")
                }
                Button {
                    store.send(.editTapped)
                } label: {
                    Text("Edit")
                        .underline()
                }
                .buttonStyle(.link)
                .padding()
            }
            .contextMenu {
                Button {
                    store.send( .deleteTapped)
                } label: {
                    Text("Delete item")
                }
            }
        }
    }
}
