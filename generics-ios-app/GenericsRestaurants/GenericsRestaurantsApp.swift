//
//  GenericsRestaurantsApp.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 14/02/2023.
//

import SwiftUI

@main
struct GenericsRestaurantsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WindowGroup("New pizza", id: "new-pizza") {
            Text("Hello world!")
        }
    }
}
