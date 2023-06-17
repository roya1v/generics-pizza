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

    @StateObject var model = CartViewModel()
    // Fix for tab bar not reappering
    @State var dumbFix = false

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
                                Image("pizzza_placeholder")
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
                                        Text("\(item.formattedPrice())")
                                        Spacer()
                                    }
                                    .padding(2.0)
                                }
                                Button {
                                    model.remove(item)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(Color.red)
                                }

                            }

                        }
                    }
                    Section {
                        NavigationLink {
                            AddressSwiftUIView(dumbFix: $dumbFix)
                                .ignoresSafeArea()
                                .toolbar(.hidden, for: .navigationBar)
                                .toolbar(dumbFix ? .hidden : .automatic,
                                         for: .tabBar)
                        } label: {
                            SelectorView(caption: "Your delivery address",
                                         icon: "location",
                                         text: "Select your address")
                        }
                        NavigationLink {
                            Text("Payment view")
                        } label: {
                            SelectorView(caption: "Payment method",
                                         icon: "creditcard",
                                         text: "Cash")
                        }
                    }
                    Section {
                        VStack {
                            ForEach(model.subtotal.dropLast(1), id: \.0) { pair in
                                HStack {
                                    Text(pair.0)
                                    Spacer()
                                    Text(pair.1)

                                }
                                .foregroundColor(Color.gray)
                                .font(.genericsCaption)
                            }
                            Divider()
                            HStack {
                                Text(model.subtotal.last!.0)
                                Spacer()
                                Text(model.subtotal.last!.1)
                            }
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
