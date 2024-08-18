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
import clients_libraries_GenericsUI
import ComposableArchitecture

struct MenuDetailView: View {

    @Environment(\.dismiss) var dismiss
    var store: Store<MenuDetailFeature.State, MenuDetailFeature.Action>

    private let gradient = LinearGradient(
        gradient: Gradient(
            colors: [.white, .gLight]),
        startPoint: UnitPoint(
            x: 0.5, y: 0.2),
        endPoint: UnitPoint(
            x: 0.5, y: 1)
      )

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                ZStack {
                    RoundedRectangle(cornerRadius: 32.0)
                        .fill(gradient)
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
                store.send(.addTapped)
                dismiss()
            } label: {
                Text("Add to cart for 6.99$")
                    .frame(maxWidth: .infinity)
                    .frame(height: 32.0)
            }
            .buttonStyle(GPrimaryButtonStyle())
            .padding()
            .padding([.bottom])
            .background(.thinMaterial)
        }
        .ignoresSafeArea()
        .navigationTitle(store.item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.white)
                        .padding(.gNormal)
                        .background(Circle().fill(Color.gAccent))
                }
            }
        }
    }
}

//#Preview {
//    NavigationView {
//        MenuDetailView(item: MenuItem(
//            id: nil,
//            title: "Super Pepperoni",
//            description: "",
//            price: 699)
//        )
//    }
//}
