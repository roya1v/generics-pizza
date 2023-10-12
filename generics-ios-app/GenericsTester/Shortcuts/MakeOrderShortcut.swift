//
//  MakeOrderShortcut.swift
//  GenericsTester
//
//  Created by Mike S. on 12/10/2023.
//

import Foundation
import GenericsCore

final class MakeOrderShortcut: TestShortcut {
    let name = "Make order"

    var menuRepository = buildMenuRepository(url: url)
    var orderRepository = buildOrderRepository(url: url)

    func perform() async throws {
        let items = try await menuRepository.fetchMenu()
        print("Found menu items: \(items)")

        orderRepository.add(item: items.first!)
        orderRepository.address = .init(coordinate: .init(latitude: 0, longitude: 0), details: "")
        print("Making order")
        let test = try await orderRepository.placeOrder()
        print("Order made: \(test)")
    }
}
