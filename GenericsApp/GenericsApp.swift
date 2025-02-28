import SwiftUI
import ComposableArchitecture

import MapKit
let restaurantCoordinates = CLLocationCoordinate2D(
    latitude: 52.2318,
    longitude: 21.0060
)

@main
struct GenericsApp: App {
    static let store = Store(initialState: AppFeature.State(cart: Shared([]),
                                                            destination: Shared(.pickUp))) {
        AppFeature()
            ._printChanges()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: GenericsApp.store)
        }
    }
}
