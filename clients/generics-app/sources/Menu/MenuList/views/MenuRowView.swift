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
        WithPerceptionTracking {
            HStack {
                image
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
                        Text(store.item.formattedPrice())
                            .font(.caption)
                    }
                    .buttonStyle(GPrimaryButtonStyle())
                }
            }
            .onTapGesture {
                store.send(.rowTapped)
            }
        }
    }

    @ViewBuilder
    private var image: some View {
        WithPerceptionTracking {
            if let image = store.image {
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
        }
    }
}
