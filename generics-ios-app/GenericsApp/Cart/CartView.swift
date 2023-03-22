//
//  CartView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import Factory

struct CartView: View {

    @ObservedObject var model = CartViewModel()

    var body: some View {
        List {
            Section("Items") {
                ForEach(model.items) { item in
                    Text(item.title)
                }
            }
            Button {
                model.placeOrder()
            } label: {
                Text("Place order")
            }

            ForEach(model.events, id: \.self) { item in
                Text(item)
            }
        }
        .onAppear {
            model.fetch()
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
