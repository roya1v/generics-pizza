import ComposableArchitecture
import Factory
import GenericsCore
import SharedModels
import SwiftUI

struct MenuView: View {

    @Perception.Bindable var store: StoreOf<MenuFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.menuState {
                case .loading:
                    ProgressView()
                case .loaded:
                    List {
                        ForEach(
                            store.scope(state: \.menuState.items, action: \.item),
                            id: \.state.id
                        ) { childStore in
                            MenuItemView(store: childStore)
                        }
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                case .error(let message):
                    VStack {
                        Text(message)
                        Button("Retry") {
                            store.send(.shown)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("New") {
                        store.send(.newItemButtonTapped)
                    }
                }
            }
            .navigationTitle("Menu")
            .confirmationDialog(
                $store.scope(state: \.deleteConfirmationDialog, action: \.deleteConfirmationDialog)
            )
            .sheet(item: $store.scope(state: \.itemForm, action: \.itemForm)) { childStore in
                MenuItemFormView(store: childStore)
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}
