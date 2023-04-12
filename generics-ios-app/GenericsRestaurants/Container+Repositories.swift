//
//  Container+Repositories.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 12/04/2023.
//

import Foundation
import Factory
import GenericsRepositories

fileprivate let url = "http://localhost:8080"

extension Container {
    static let orderRepository = Factory(scope: .singleton) { buildOrderRepository(url: url) }
    static let menuRepository = Factory { buildMenuRepository(url: url)}
    static let orderRestaurantRepository = Factory(scope: .singleton) { buildOrderRestaurantRepository(url: url) }
}
