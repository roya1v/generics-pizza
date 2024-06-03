//
//  ContentView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/02/2023.
//

import SwiftUI
import Combine
import Factory
import GenericsCore

struct ContentView: View {

    @State var state: AuthenticationState = .unknown
    @Injected(\.authenticationRepository) private var repository

    var body: some View {
        Group {
            switch state {
            case .unknown:
                Text("")
            case .loggedIn:
                DashboardView()
            case .loggedOut:
                LoginView()
            }
        }
        .onReceive(
            repository
                .statePublisher
                .receive(on: DispatchQueue.main)
        ) { state in
            self.state = state
        }
        .onAppear {
            repository.reload()
        }
    }
}

#Preview {
    ContentView()
}
