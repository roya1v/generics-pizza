import SwiftUI
import ComposableArchitecture

struct MenuListView: View {

    let store: StoreOf<MenuListFeature>

    var body: some View {
        WithPerceptionTracking {
            ScrollViewReader { proxy in
                List {
                    ForEach(store.scope(state: \.items, action: \.row)) { childStore in
                        WithPerceptionTracking {
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
}
