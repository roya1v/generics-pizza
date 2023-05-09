//
//  CartView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import Factory
import GenericsRepositories
import GenericsUI

struct CartView: View {

    @ObservedObject var model = CartViewModel()

    @State var count = 0

    var body: some View {
        NavigationView {
            if model.items.isEmpty {
                Text("You have to first add items to your cart!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            } else {
                List {
                    Section {
                        ForEach(model.items) { item in
                            HStack {
                                Image("menu_pizza")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80.0, height: 80.0)
                                VStack(alignment: .leading) {
                                    Text(item.title)
                                    Text(item.description)
                                        .font(.genericsCaption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                    HStack {
                                        Text("$13.99")
                                        Spacer()
                                    }
                                    .padding(2.0)
                                }

                            }
                        }
                    }
                    Section {
                        VStack {
                            HStack {
                                Text("Subtotal")
                                Spacer()
                                Text("14.44$")

                            }
                            .foregroundColor(Color.gray)
                            .font(.genericsCaption)
                            HStack {
                                Text("Delivery")
                                Spacer()
                                Text("14.44$")

                            }
                            .foregroundColor(Color.gray)
                            .font(.genericsCaption)
                            Divider()
                            HStack {
                                Text("Total")
                                Spacer()
                                Text("14.44$")
                            }
                        }
                    }
                    Section {
                        NavigationLink {
                            AddressSwiftUIView()
                                .ignoresSafeArea()
                                .toolbar(.hidden, for: .navigationBar)
                        } label: {
                            SelectorCardView(caption: "Your delivery address",
                                             icon: "location",
                                             text: "1234 Generic's street Warsaw")
                        }
                        NavigationLink {
                            Text("Payment view")
                        } label: {
                            SelectorCardView(caption: "Payment method",
                                             icon: "creditcard",
                                             text: "Cash")
                        }
                    }
                    Section {
                        switch model.state {
                        case .readyForOrder:
                            orderButton
                        case .loading:
                            ProgressView()
                        case .inOrderState(_):
                            liveOrder
                        case .error:
                            Text("Something didn't work out :(")
                        }
                    }
                }
                .navigationTitle("My cart")
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

    @ViewBuilder
    var orderButton: some View {
        Button {
            model.placeOrder()
        } label: {
            Text("Place order")
                .font(.headline)
                .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .contentShape(Rectangle())
                        .foregroundColor(Color.white)
                        .background(Color.black)

        }
            .listRowInsets(EdgeInsets())

    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        Container.orderRepository.register { mockOrderRepository() }
        return CartView()
    }
}

struct SelectorCardView: View {

    let caption: String
    let icon: String
    let text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(caption)
                .font(.genericsCaption)
                .foregroundColor(Color.gray)
                .padding(1.0)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.gray)
                Text(text)
            }
        }
    }
}

