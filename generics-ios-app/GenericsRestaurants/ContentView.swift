//
//  ContentView.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 14/02/2023.
//

import SwiftUI
import Combine
import Factory

struct ContentView: View {

    @State var state: AuthenticationState = .loggedOut
    @Injected(Container.authenticationRepository) private var repository

    var body: some View {
        Group {
            if state == .loggedOut {
                LoginView()
            } else {
                DashboardView()
                    .padding()
            }
        }
        .onReceive(repository.state) { state in
            self.state = state
        }
        .onAppear {
            repository.reload()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
