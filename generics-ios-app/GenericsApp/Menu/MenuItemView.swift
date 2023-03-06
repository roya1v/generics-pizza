//
//  MenuItemView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI
import Factory
import GenericsUIKit

struct MenuItemView: View {
    let name: String
    let description: String

    var body: some View {
        CardView {
            VStack {
                Image("menu_pizza")
                    .resizable()
                    .scaledToFit()
                Spacer()
                VStack(alignment: .leading) {
                    Text(name)
                    Text(description)
                        .font(.system(size: 12.0, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
}

struct MenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        Container.menuRepository.register { MenuRepositoryMck() }
        return MenuView()
    }
}
