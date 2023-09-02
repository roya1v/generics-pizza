//
//  Container+Repositories.swift
//  GenericsApp
//
//  Created by Mike S. on 10/04/2023.
//

import Foundation
import Factory
import GenericsCore

fileprivate let url = "http://localhost:8080"

extension Container {
    static let orderRepository = Factory(scope: .singleton) { buildOrderRepository(url: url) }
    static let menuRepository = Factory { buildMenuRepository(url: url) }
    static let authenticationRepository = Factory(scope: .singleton) { buildAuthenticationRepository(url: url) }
    static let geocodingService = Factory { buildGeocodingService() }
}
