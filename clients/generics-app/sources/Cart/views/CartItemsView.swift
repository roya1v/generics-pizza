import SwiftUI
import ComposableArchitecture
import clients_libraries_GenericsUI

struct CartItemsView: View {

    let store: StoreOf<CartFeature>

    var body: some View {
        WithPerceptionTracking {
            ForEach(store.items) { item in
                WithPerceptionTracking {
                    VStack(alignment: .leading) {
                        HStack {
                            Image("menu_pizza")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 75.0)
                            VStack {
                                Text(item.title)
                                Text(item.description)
                                    .font(.gCaption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        HStack {
                            Text(item.formattedPrice())
                            Spacer()
                            Button {
                                store.send(.removeTapped(item))
                            } label: {
                                Text("Delete")
                                    .font(.caption)
                            }
                            .buttonStyle(GPrimaryButtonStyle())
                        }
                    }
                }
            }
        }
    }
}
