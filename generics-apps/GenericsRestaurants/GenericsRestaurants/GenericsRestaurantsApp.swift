//
//  GenericsRestaurantsApp.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/02/2023.
//

import SwiftUI

@main
struct GenericsRestaurantsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        Window("New pizza", id: "new-pizza") {
            NewMenuItemView()
        }
        .windowResizability(.contentSize)
    }
}
