import SwiftUI
import ComposableArchitecture

@main
struct GenericsDriver: App {

    static let store = Store(initialState: AppFeature.State.splash) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
