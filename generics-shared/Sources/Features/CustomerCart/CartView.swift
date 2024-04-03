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

public struct CartView: View {

    @StateObject var model = CartViewModel()

    public init() { }

    public var body: some View {
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
            getImage(for: item)
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
                Image(systemName: "minus")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

        }
    }

    func getImage(for item: MenuItem) -> some View {
        Group {
            if let url = model.imageUrl(for: item) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure(_), .empty:
                        Image("pizzza_placeholder")
                            .resizable()
                            .scaledToFit()
                    @unknown default:
                        fatalError()
                    }
                }
                .frame(width: 75.0)
            } else {
                Image("pizzza_placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75.0)
            }
        }
    }

    // MARK: Details section

    @ViewBuilder
    var detailsSection: some View {
        Section {
            Picker("Delivery method", selection: $model.isPickUp) {
                Text("Pick up").tag(true)
                Text("Delivery").tag(false)
            }
            .pickerStyle(.segmented)
            if (!model.isPickUp) {
                NavigationLink {
                    VStack {
                        TextField("Address", text: $model.address)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                        Spacer()
                    }
                } label: {
                    SelectorView(caption: "Your delivery address",
                                 icon: "location",
                                 text: "Enter your address")
                }
            }
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

#Preview {
    let _ = Container.shared.orderRepository.register { mockOrderRepository() }
    return CartView()
}
