//
//  HomeView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import GenericsUI

struct HomeView: View {

    var body: some View {
        NavigationView {
            ScrollView {
                BigImageCardView(title: "Lorem ipsum",
                                 subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                                 ctaTitle: "CTA") {
                    Image("pizza")
                        .resizable()
                        .scaledToFit()
                } action: {

                }
                .padding([.leading, .trailing])

                CtaCardView(title: "Lorem ipsum",
                            subtitle: "Lorem ipsum dolor sit amet, consectetur adipiscing elit... ",
                            ctaTitle: "CTA") {

                }
                .padding([.leading, .trailing])

                CarouselCardView()
                .padding([.leading, .trailing])

            }

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .navigationTitle("Welcome back")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
