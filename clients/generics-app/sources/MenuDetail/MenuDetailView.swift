//
//  MenuDetailView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import Factory
import SharedModels
import clients_libraries_GenericsCore

struct MenuDetailView: View {
    
    static let gradientStart = Color(red: 239.0 / 255, green: 120.0 / 255, blue: 221.0 / 255)
    static let gradientEnd = Color(red: 239.0 / 255, green: 172.0 / 255, blue: 120.0 / 255)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                ZStack {
                    RoundedRectangle(cornerRadius: 32.0)
                        .fill(LinearGradient(
                            gradient: .init(colors: [.white, .gray]),
                            startPoint: .init(x: 0.5, y: 0.2),
                            endPoint: .init(x: 0.5, y: 1)
                          ))
                    VStack {
                        Image("menu_pizza")
                            .resizable()
                            .scaledToFit()
                            .padding()
                        // How to do that correctly on iOS 16?
                            .padding([.top], 72.0)
                            
                        Picker(
                            "Size",
                            selection: .constant("medium")
                        ) {
                            Text("Small")
                                .tag("small")
                            Text("Medium")
                                .tag("medium")
                            Text("Large")
                                .tag("large")
                        }
                        .pickerStyle(.segmented)
                        .padding([.horizontal])
                        Picker(
                            "Dough",
                            selection: .constant("regular")
                        ) {
                            Text("Regular")
                                .tag("regular")
                            Text("Thin")
                                .tag("thin")
                        }
                        .pickerStyle(.segmented)
                        .padding([.horizontal, .bottom])
                    }
                }
                Grid {
                    ForEach(0..<9) { _ in
                        GridRow {
                            ForEach(0..<3) { _ in
                                VStack {
                                    Image(systemName: "wineglass")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 54.0)
                                    Text("Extra ingridient")
                                        .font(.gCaption)
                                        .multilineTextAlignment(.center)
                                    Text("0.99$")
                                }
                                .padding()
                            }
                        }
                    }
                }

            }
            Button {
                print("Hello world")
            } label: {
                Text("Add to cart for 6.99$")
                    .frame(maxWidth: .infinity)
                    .frame(height: 32.0)
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .padding()
            .padding([.bottom])
            .background(.thinMaterial)
        }
        .ignoresSafeArea()
        .navigationTitle("Super Pepperoni")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        MenuDetailView()
    }
}
