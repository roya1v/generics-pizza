//
//  Container+Repositories.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 12/04/2023.
//

import Foundation
import Factory
import GenericsCore

fileprivate let url = "http://localhost:8080"

extension Container {
    var authenticationRepository: Factory<AuthenticationRepository> {
        self { buildAuthenticationRepository(url: url) }
            .singleton
    }

    var orderRestaurantRepository: Factory<OrderRestaurantRepository> {
        self { buildOrderRestaurantRepository(url: url) }
            .singleton
    }

    var menuRepository: Factory<MenuRepository> {
        self { buildMenuRepository(url: url) }
    }

    var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: url) }
            .singleton
    }

    var usersRepository: Factory<UsersRepository> {
        self { buildUsersRepository(url: url) }
            .singleton
    }
}
