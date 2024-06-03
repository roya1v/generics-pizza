//
//  ContentView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import CustomerMenu
import CustomerCart

struct ContentView: View {

    var body: some View {
        TabView {
            MenuView()
                .tabItem {
                    Label("Menu", systemImage: "menucard")
                }
            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
        }
    }
}

#Preview {
    ContentView()
}

