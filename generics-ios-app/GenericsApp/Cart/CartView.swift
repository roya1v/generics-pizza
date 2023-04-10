//
//  CartView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import Factory
import GenericsRepositories

struct CartView: View {

    @ObservedObject var model = CartViewModel()

    var body: some View {
        Group {
            if model.items.isEmpty {
                Text("You have to first add items to your cart!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            } else {
                List {
                    Section("Items") {
                        ForEach(model.items) { item in
                            HStack {
                                Image("menu_pizza")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40.0, height: 40.0)
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                    Text(item.description)
                                        .font(.genericsCaption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
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
                    case .inOrderState(_):
                        liveOrder
                    case .error:
                        Text("Something didn't work out :(")
                    }
                }
            }
        }
        .onAppear {
            model.fetch()
        }
    }

    @ViewBuilder
    var liveOrder: some View {
        if case let .inOrderState(state) = model.state {
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
        } else {
            Text("Something didn't work out :(")
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        Container.orderRepository.register { mockOrderRepository() }
        return CartView()
    }
}
