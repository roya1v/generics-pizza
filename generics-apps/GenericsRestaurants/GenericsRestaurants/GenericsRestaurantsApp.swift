//
//  GenericsRestaurantsApp.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/02/2023.
//

import SwiftUI
import Factory
import ComposableArchitecture

@main
struct GenericsRestaurantsApp: App {

    @Injected(\.authenticationRepository) private var repository

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Sign out") {
                    Task {
                        try? await repository.signOut()
                    }
                }
            }
        }
    }
}
