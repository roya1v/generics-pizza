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
                CardView {
                    VStack {
                        Image("pizza")
                            .resizable()
                            .scaledToFit()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Lorem ipsum")
                                    .font(.title)
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit... ")
                                    .multilineTextAlignment(.leading)
                            }
                            Button("CTA") {
                                print("CTA")
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding([.leading, .trailing, .bottom], 10.0)
                    }
                }
                .padding()

                CardView {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Lorem ipsum")
                                .font(.title)
                            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit... ")
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                        }
                        Button("CTA") {
                            print("CTA")
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                }
                .padding()

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
                    .padding([.leading, .trailing, .bottom], 10.0)
                }
                .padding()
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
