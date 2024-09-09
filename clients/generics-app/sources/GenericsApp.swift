import SwiftUI
import ComposableArchitecture

@main
struct GenericsApp: App {
    static let store = Store(initialState: AppFeature.State(cart: Shared([]),
                                                            destination: Shared(.pickUp))) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: GenericsApp.store)
        }
    }
}
