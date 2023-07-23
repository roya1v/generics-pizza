//
//  CtaCardView.swift
//  GenericsApp
//
//  Created by Mike S. on 23/07/2023.
//

import SwiftUI
import GenericsUI

struct CtaCardView: View {

    let title: String
    let subtitle: String
    let ctaTitle: String
    let action: () -> Void

    var body: some View {
        CardView {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title)
                    Text(subtitle)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                Button(ctaTitle, action: action)
                .buttonStyle(.bordered)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct CtaCardView_Previews: PreviewProvider {
    static var previews: some View {
        CtaCardView(title: "Lorem ipsum",
                    subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                    ctaTitle: "CTA") {

        }
    }
}
