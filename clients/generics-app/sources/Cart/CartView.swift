//
//  CartView.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import SwiftUI
import Factory
import clients_libraries_GenericsCore
import clients_libraries_GenericsUI
import SharedModels
import ComposableArchitecture

struct CartView: View {

    let store: StoreOf<CartFeature>

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            mainBody
                .navigationTitle("Cart")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                        }

                    }
                }
        }
        .task {
            store.send(.appeared)
        }
    }

    @ViewBuilder
    var mainBody: some View {
        List {
            cartSection
            totalSection
            ctaSection
        }
    }

    // MARK: Cart section

    @ViewBuilder
    var cartSection: some View {
        Section {
            ForEach(store.items) { item in
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
                    .font(.gCaption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                HStack {
                    Text(item.formattedPrice())
                    Spacer()
                }
                .padding(2.0)
            }
            Button {
                store.send(.removeTapped(item))
            } label: {
                Image(systemName: "minus")
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

        }
    }

    func getImage(for item: MenuItem) -> some View {
        Group {
//            if let url = model.imageUrl(for: item) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .scaledToFit()
//                    case .failure, .empty:
//                        Image("pizzza_placeholder")
//                            .resizable()
//                            .scaledToFit()
//                    @unknown default:
//                        fatalError()
//                    }
//                }
//                .frame(width: 75.0)
//            } else {
//                Image("pizzza_placeholder")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 75.0)
//            }
        }
    }

    // MARK: Details section

    // MARK: Total section

    @ViewBuilder
    var totalSection: some View {
        Section {
            VStack {
                ForEach(store.subtotal, id: \.name) { part in
                    if part.isSecondary {
                        HStack {
                            Text(part.name)
                            Spacer()
                            Text(part.formattedPrice())
                        }
                        .foregroundColor(Color.gray)
                        .font(.gCaption)
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
            switch store.subState {
            case .readyForOrder:
                orderButton
            case .loading:
                ProgressView()
            case .inOrderState:
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
        if case let .inOrderState(state) = store.subState {
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
            store.send(.placeOrder)
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

//#Preview {
//    _ = Container.shared.orderRepository.register { mockOrderRepository() }
//    return CartView()
//}
