//
//  MenuItemView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI
import Factory
import GenericsUI

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
                        .font(.genericsCaption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    Text("13.99$")
                        .font(.system(size: 16.0, weight: .bold))
                        .padding(4.0)
                }
                .frame(maxHeight: 100.0)
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
