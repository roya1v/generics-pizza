import SwiftUI
import ComposableArchitecture
import SharedModels

struct MenuListView: View {

    let store: StoreOf<MenuListFeature>

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(store.scope(state: \.items, action: \.row)) { childStore in
                    MenuRowView(store: childStore)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .id(childStore.state.id)
                        .onAppear {
                            childStore.send(.rowAppeared)
                        }
                        .onDisappear {
                            childStore.send(.rowDisappeared)
                        }
                }
            }
            .listStyle(.plain)
            .onReceive(store.publisher.scrolledTo) { item in
                if let item {
                    withAnimation {
                        proxy.scrollTo(item.id, anchor: .top)
                        store.send(.updatedScroll)
                    }
                }
            }
        }
    }
}

extension MenuListFeature.State {
    static let preview = MenuListFeature.State(
        items: [
            MenuRowFeature.State(
                item: MenuItem(
                    id: UUID(0),
                    title: "Generic Pizza",
                    description: "Super generic pizza for generic hunger",
                    price: 999,
                    isHidden: false,
                    category: MenuItem.Category(
                        id: UUID(0),
                        name: "Pizza"
                    )
                ),
                image: UIImage(named: "generic_pizza"),
                isVisible: true
            )
        ],
        scrolledTo: nil
    )
}

#Preview {
    MenuListView(store: Store(initialState: .preview) {
        EmptyReducer()
    })
}
