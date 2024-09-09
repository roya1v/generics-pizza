import SwiftUI
import Combine
import Factory
import clients_libraries_GenericsCore
import ComposableArchitecture

struct ContentView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .loading:
                    Text("")
                case .auth(.login):
                    if let store = store.scope(
                        state: \.auth.login,
                        action: \.auth.login) {
                        LoginView(store: store)
                    }
                case .auth(.createAccount):
                    if let store = store.scope(
                        state: \.auth.createAccount,
                        action: \.auth.createAccount) {
                        CreateAccountView(store: store)
                    }
                case .dashboard:
                    if let store = store.scope(
                        state: \.dashboard,
                        action: \.dashboard) {
                        DashboardView(store: store)
                    }

                }
            }
            .task {
                store.send(.launched)
            }
        }
    }
}
