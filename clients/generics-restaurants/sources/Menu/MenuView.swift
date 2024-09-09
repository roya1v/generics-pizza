import SwiftUI
import Factory
import clients_libraries_GenericsCore
import SharedModels
import ComposableArchitecture

struct MenuView: View {

    @Perception.Bindable var store: StoreOf<MenuFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.menuState {
                case .loading:
                    ProgressView()
                case .loaded(let items):
                    List {
                        ForEach(items) { item in
                            listRow(for: item)
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
            .confirmationDialog($store.scope(state: \.deleteConfirmationDialog, action: \.deleteConfirmationDialog))
            .sheet(item: $store.scope(state: \.newItem, action: \.newItem)) { newItemStore in
                NewMenuItemView(store: newItemStore)
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }

    func listRow(for item: MenuFeature.State.Item) -> some View {
        HStack {
            if let image = item.image {
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
                Text(item.item.title)
                    .font(.title2)
                Text(item.item.description)
                    .font(.caption)
            }
            Spacer()
            Text(item.item.formattedPrice())
                .bold()
                .padding()
            Button {

            } label: {
                Text("Edit")
                    .underline()
            }
            .buttonStyle(.link)
            .padding()
        }
        .contextMenu {
            Button {
                store.send(.delete(item.item))
            } label: {
                Text("Delete item")
            }
        }
    }
}
