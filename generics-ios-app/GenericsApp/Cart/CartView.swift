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
            switch model.state {
            case .readyForOrder:
                Button {
                    model.placeOrder()
                } label: {
                    Text("Place order")
                }
            case .loading:
                ProgressView()
            case .inOrderState(let state):
                switch state {
                case .new:
                    Text("We have just received your order!")
                case .inProgress:
                    Text("Our team is working on your order!")
                case .readyForDelivery:
                    Text("One of our drivers will soon deliver your order!")
                case .inDelivery:
                    Text("Your order is being delivered!")
                case .finished:
                    Text("Enjoy your food!")
                }
            }
        }
        .onAppear {
            model.fetch()
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        Container.orderRepository.register { OrderRepositoryMck() }
        return CartView()
    }
}
