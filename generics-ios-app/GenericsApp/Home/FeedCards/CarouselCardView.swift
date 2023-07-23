//
//  CarouselCardView.swift
//  GenericsApp
//
//  Created by Mike S. on 23/07/2023.
//

import SwiftUI
import GenericsUI

// What should one cell be?
struct CarouselCardView: View {
    var body: some View {
        CardView {
            VStack(alignment: .leading) {
                Text("Lorem ipsum")
                    .font(.title)
                HStack {
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                    Image("menu_pizza")
                        .resizable()
                        .scaledToFit()
                }
            }
            .padding()
        }
    }
}

struct CarouselCardView_Previews: PreviewProvider {
    static var previews: some View {
        CarouselCardView()
    }
}
