import SwiftUI
import Factory
import ComposableArchitecture

@main
struct GenericsRestaurantsApp: App {
    
    static let store = Store(initialState: AppFeature.State.loading) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Sign out") {
                    Self.store.send(.dashboard(.signOutTapped))
                }
            }
        }
    }
}
