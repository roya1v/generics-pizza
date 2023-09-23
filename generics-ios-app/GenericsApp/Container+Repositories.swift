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
    var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: url) }
            .singleton
    }

    var menuRepository: Factory<MenuRepository> {
        self { buildMenuRepository(url: url) }
            .singleton
    }
    var authenticationRepository: Factory<AuthenticationRepository> {
        self { buildAuthenticationRepository(url: url) }
            .singleton
    }
    var geocodingService: Factory<GeocodingService> {
        self { buildGeocodingService() }
            .singleton
    }
}
