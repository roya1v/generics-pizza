//
//  CartView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import Factory
import GenericsCore
import GenericsUI
import SharedModels

struct CartView: View {

    @StateObject var model = CartViewModel()

    var body: some View {
        NavigationView {
            switch model.state {
            case .needItems:
                Text("You have to first add items to your cart!")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
            case .readyForOrder, .loadingOrderDetails, .loading, .inOrderState(_), .error:
                mainBody
                    .navigationTitle("My cart")
            }
        }
        .onAppear {
            model.fetch()
        }
    }

    @ViewBuilder
    var mainBody: some View {
        List {
            cartSection
            detailsSection
            totalSection
            ctaSection
        }
    }

    // MARK: Cart section

    @ViewBuilder
    var cartSection: some View {
        Section {
            ForEach(model.items) { item in
                getCartItem(for: item)
            }
        }
    }

    private func getCartItem(for item: MenuItem) -> some View {
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
                    Text(item.formattedPrice())
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

    // MARK: Details section

    @ViewBuilder
    var detailsSection: some View {
        Section {
            NavigationLink {
                Text("Address view")
            } label: {
                SelectorView(caption: "Your delivery address",
                             icon: "location",
                             text: "Select your address")
            }
            .disabled(true)
            NavigationLink {
                Text("Payment view")
            } label: {
                SelectorView(caption: "Payment method",
                             icon: "creditcard",
                             text: "Cash")
            }
            .disabled(true)
        }
    }

    // MARK: Total section

    @ViewBuilder
    var totalSection: some View {
        Section {
            VStack {
                ForEach(model.subtotal, id: \.name) { part in
                    if part.isSecondary {
                        HStack {
                            Text(part.name)
                            Spacer()
                            Text(part.formattedPrice())
                        }
                        .foregroundColor(Color.gray)
                        .font(.genericsCaption)
                    } else {
                        Divider()
                        HStack {
                            Text(part.name)
                            Spacer()
                            Text(part.formattedPrice())
                        }
                    }
                }
            }
        }
    }

    // MARK: CTA section

    @ViewBuilder
    var ctaSection: some View {
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
            case .needItems:
                Text("Hello")
            case .loadingOrderDetails:
                Text("This shouldn't be here")
            }
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
        Container.shared.orderRepository.register { mockOrderRepository() }
        return CartView()
    }
}
