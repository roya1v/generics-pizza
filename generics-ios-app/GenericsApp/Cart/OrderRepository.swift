//
//  OrderRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import GenericsModels
import GenericsHttp
import Factory

extension Container {
    static let orderRepository = Factory(scope: .singleton) { OrderRepository() as OrderRepository }
}

final class OrderRepository {

    private var items = [MenuItem]()

    func add(item: MenuItem) {
        items.append(item)
    }

    func placeOrder() async throws {
        try await GenericsHttp(baseURL: "http://localhost:8080")!
            .add(path: "order")
            .body(OrderModel(items: items))
            .perform()
    }
}
