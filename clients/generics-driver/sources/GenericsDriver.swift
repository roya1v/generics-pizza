import SwiftUI
import ComposableArchitecture

import MapKit
let restaurantCoordinates = CLLocationCoordinate2D(
    latitude: 52.2318,
    longitude: 21.0060
)

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
