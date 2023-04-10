//
//  Container+Repositories.swift
//  GenericsApp
//
//  Created by Mike S. on 10/04/2023.
//

import Foundation
import Factory
import GenericsRepositories

let url = "http://localhost:8080"

extension Container {
    static let orderRepository = Factory(scope: .singleton) { buildOrderRepository(url: url) }
    static let menuRepository = Factory { buildMenuRepository(url: url)}
}
