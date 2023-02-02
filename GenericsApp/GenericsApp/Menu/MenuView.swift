//
//  MenuView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI

struct MenuView: View {

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                CardView {
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                }
                .padding()
                CardView {
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                }
                .padding()
                CardView {
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                }
                .padding()
                CardView {
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                }
                .padding()
            }
        }

    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
