//
//  MenuItemView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI

struct MenuItemView: View {
    var body: some View {
        CardView {
            VStack {
                Image("menu_pizza")
                    .resizable()
                    .scaledToFit()
                Text("Margarita simplita")
                Text("Tomatoe souce, cheese and weird leaves")
                    .font(.system(size: 12.0, weight: .regular))
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
