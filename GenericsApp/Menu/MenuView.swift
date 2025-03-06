import ComposableArchitecture
import Factory
import GenericsCore
import SharedModels
import SwiftUI

struct MenuView: View {

    @Bindable
    var store: StoreOf<MenuFeature>

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: .gXL)
                .fill(Color.white)
                .ignoresSafeArea()

            VStack {
                switch store.contentState {
                case .loading:
                    ProgressView()
                case .error:
                    error
                case .loaded:
                    menu
                }
            }
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.menuDetail,
                action: \.menuDetail
            )
        ) { item in
            NavigationView {  // So we see the nav title
                MenuDetailView(store: item)
            }
        }
        .task {
            store.send(.appeared)
        }
    }

    var menu: some View {
        WithPerceptionTracking {
            MenuHeaderView(store: store.scope(state: \.header, action: \.header))
            MenuListView(store: store.scope(state: \.list, action: \.list))
        }
    }

    @ViewBuilder
    var error: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView {
                Label("Server error", systemImage: "exclamationmark.icloud")
            } description: {
                Text("There was an error while fetching the menu")
            } actions: {
                Button("Refresh") {
                    store.send(.refreshTapped)
                }
            }
        } else {
            VStack {
                Text("Server error")
                    .font(.largeTitle)
                Image(systemName: "exclamationmark.icloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100.0, height: 100.0)
                Text("There was an error while fetching the menu")
                Button("Refresh") {
                    store.send(.refreshTapped)
                }
            }
        }
    }
}
