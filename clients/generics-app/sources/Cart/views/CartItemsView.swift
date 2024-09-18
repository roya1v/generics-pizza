import SwiftUI
import ComposableArchitecture
import clients_libraries_GenericsUI

struct CartItemsView: View {

    let store: StoreOf<CartFeature>

    var body: some View {
        WithPerceptionTracking {
            ForEach(
                store.scope(state: \.items, action: \.item),
                id: \.state.id
            ) { childStore in
                WithPerceptionTracking {
                    VStack(alignment: .leading) {
                        HStack {
                            if let image = childStore.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75.0)
                            } else {
                                Image("pizzza_placeholder")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 75.0)
                            }
                            VStack {
                                Text(childStore.menuItem.title)
                                Text(childStore.menuItem.description)
                                    .font(.gCaption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                        }
                        HStack {
                            Text(childStore.menuItem.formattedPrice())
                            Spacer()
                            CountButton(store: childStore)
                        }
                    }
                }
            }
        }
    }
}

struct CountButton: View {

    let store: StoreOf<CartItemFeature>

    var body: some View {
        WithPerceptionTracking {
            HStack {
                Button {
                    store.send(.decreaseTapped)
                } label: {
                    Text("-")

                }
                .buttonStyle(GLinkButtonStyle())
                Text("\(store.count)")
                Button {
                    store.send(.increaseTapped)
                } label: {
                    Text("+")

                }
                .buttonStyle(GLinkButtonStyle())
            }
            .padding([.leading, .trailing])
            .background(Color.gLight)
            .clipShape(RoundedRectangle(cornerRadius: 16.0))
        }
    }
}
