import GenericsUI
import SharedModels
import SwiftUI
import ComposableArchitecture

@Reducer
struct MenuRowFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        var item: MenuItem
        var image: UIImage?
        var isVisible = false

        var id: UUID? {
            item.id
        }
    }

    enum Action {
        // View
        case rowTapped
        case rowAppeared
        case rowDisappeared

        // Internal
        case imageLoaded(Result<UIImage, Error>)
    }
}

struct MenuRowView: View {

    let store: StoreOf<MenuRowFeature>

    var body: some View {
        HStack {
            image
                .frame(width: 160.0)
            VStack(alignment: .leading) {
                Text(store.item.title)
                    .font(.headline)
                Text(store.item.description)
                    .font(.gCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                Button {
                    store.send(.rowTapped)
                } label: {
                    Text("for \(store.item.formattedPrice())")
                        .font(.footnote)
                        .padding(.horizontal, .gXS)
                }
                .buttonStyle(GPrimaryPillButtonStyle())
            }
        }
        .listRowInsets(EdgeInsets())
        .padding(.trailing, .gXS)
        .onTapGesture {
            store.send(.rowTapped)
        }
    }

    @ViewBuilder
    private var image: some View {
        if let image = store.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image("pizzza_placeholder")
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    MenuRowView(
        store: StoreOf<MenuRowFeature>(
            initialState: MenuRowFeature.State(
                item: MenuItem(
                    id: nil,
                    title: "Preview pizza",
                    description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                    price: 999,
                    isHidden: false,
                    category: MenuItem.Category(
                        id: nil,
                        name: "")
                ),
                image: UIImage(named: "preview_pizza"),
                isVisible: true
            )
        ) {
            EmptyReducer()
        }
    )
}
