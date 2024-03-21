//
//  NowView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import SwiftUI
import GenericsCore
import Factory
import SharedModels

struct NowView: View {

    @StateObject var model = NowViewModel()

    var body: some View {
        List {
            Section("Orders") {
                ForEach(model.orders) { order in
                    orderRow(for: order)
                    Divider()
                }
            }
        }
        .onAppear {
            model.fetch()
        }
    }

    @ViewBuilder
    func orderRow(for order: OrderModel) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ID: \(order.id!.uuidString)")
                    .font(.caption)
                Text(order.createdAt!, style: .time)
                    .font(.caption)
                let items = order.items.reduce("", {$0 + $1.title})
                Text("**Items:** \(items)")
                switch order.type {
                case .delivery(let address):
                    Text("Delivery address: \(address)")
                case .pickUp:
                    Text("Self pick up order")
                }

            }
            Spacer()
            Button(order.state!.rawValue) {
                model.update(order, to: order.state!.next())
            }
        }
    }
}

struct NowView_Previews: PreviewProvider {
    static var previews: some View {
        Container.shared.orderRestaurantRepository.register { mockOrderRestaurantRepository() }
        return NowView()
    }
}
