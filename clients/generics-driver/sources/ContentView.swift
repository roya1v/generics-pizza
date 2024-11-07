import SwiftUI
import GenericsUI
import ComposableArchitecture

struct ContentView: View {

    let store: StoreOf<AppFeature>

    var body: some View {
        WithPerceptionTracking {
            switch store.state {
            case .splash:
                SplashView()
                    .task {
                        store.send(.appeared)
                    }
            case .dashboard:
                Text("Hello world")
            case .auth:
                if let store = store.scope(
                    state: \.auth,
                    action: \.auth) {
                    LoginView(store: store)
                }
            }
        }
    }
}