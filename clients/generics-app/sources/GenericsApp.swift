//
//  GenericsAppApp.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct GenericsApp: App {
    static let store = Store(initialState: AppFeature.State(cart: Shared([]))) {
        AppFeature()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: GenericsApp.store)
        }
    }
}
