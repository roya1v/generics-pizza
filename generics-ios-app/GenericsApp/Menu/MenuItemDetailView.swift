//
//  MenuItemDetailView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import GenericsModels

struct MenuItemDetailView: View {

    let item: MenuItem

    var body: some View {
        VStack {
            Image("menu_pizza")
                .resizable()
                .scaledToFit()
                .padding()
            Text(item.title)
                .font(.title)
            Text(item.description)
            Spacer()
            Button {
                print("ye")
            } label: {
                Text("Add to cart")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MenuItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MenuItemDetailView(item: .init(id: nil,
                                       title: "Mocked pizza",
                                       description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."))
    }
}
