import GenericsUI
import SwiftUI
import ComposableArchitecture
import SharedModels

struct MenuHeaderView: View {

    let store: StoreOf<MenuHeaderFeature>

    var body: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack {
                ForEach(store.categories) { category in
                    Button(category.name) {
                        store.send(.categorySelected(category.id), animation: .easeInOut)
                    }
                    .buttonStyle(
                        GLinkButtonStyle(
                            style: store.selected == category
                            ? .active
                            : .inactive)
                    )
                    .padding(.gXS)
                }
            }
        }
    }
}

extension MenuHeaderFeature.State {
    static let preview = MenuHeaderFeature.State(
        categories: [
            MenuItem.Category(id: UUID(0), name: "Pizza"),
            MenuItem.Category(id: UUID(1), name: "Snacks"),
            MenuItem.Category(id: UUID(2), name: "Deserts"),
            MenuItem.Category(id: UUID(3), name: "Drinks"),
            MenuItem.Category(id: UUID(4), name: "Other")
        ],
        selected: MenuItem.Category(id: UUID(1), name: "Snacks")
    )
}

#Preview {
    MenuHeaderView(
        store: Store(initialState: .preview) {
            EmptyReducer()
        }
    )
}
