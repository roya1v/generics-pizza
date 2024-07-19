//
//  ContentView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import clients_libraries_GenericsUI

struct ContentView: View {

    @State var isShowingMenu = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            MenuView()
            Button {
                isShowingMenu = true
            } label: {
                HStack {
                    Text("Cart")
                    Image(systemName: "cart")
                }
                .padding(.gNormal)
            }
            .buttonStyle(GPrimaryButtonStyle())
            .padding()
        }
        .sheet(isPresented: $isShowingMenu) {
            CartView()
        }
    }
}

#Preview {
    ContentView()
}
