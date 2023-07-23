//
//  BigImageCardView.swift
//  GenericsApp
//
//  Created by Mike S. on 23/07/2023.
//

import SwiftUI
import GenericsUI

struct BigImageCardView<ImageView>: View where ImageView: View {


    let title: String
    let subtitle: String

    let ctaTitle: String?
    let imageView: () -> ImageView
    let action: (() -> Void)?

    var body: some View {
        CardView {
            VStack {
                imageView()
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.title)
                        Text(subtitle)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    if let ctaTitle, let action {
                        Button(ctaTitle, action: action)
                        .buttonStyle(.bordered)
                    }

                }
                .padding([.leading, .trailing, .bottom])
            }
        }
    }
}

struct BigImageCardView_Previews: PreviewProvider {
    static var previews: some View {
        BigImageCardView(title: "Lorem ipsum",
                         subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                         ctaTitle: "CTA") {
            Image("pizza")
                .resizable()
                .scaledToFit()
        } action: {

        }
    }
}
