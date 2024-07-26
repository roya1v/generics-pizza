//
//  Container+Repositories.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 12/04/2023.
//

import Foundation
import Factory
import clients_libraries_GenericsCore

extension Container {
    var authenticationRepository: Factory<AuthenticationRepository> {
        self { buildAuthenticationRepository(url: self.serverUrl()) }
            .singleton
    }

    var orderRestaurantRepository: Factory<OrderRestaurantRepository> {
        self { buildOrderRestaurantRepository(
            url: self.serverUrl(),
            authenticationProvider: self.authenticationRepository())
        }
        .singleton
    }

    var menuRepository: Factory<MenuRepository> {
        self { buildMenuRepository(url: self.serverUrl(), authenticationProvider: self.authenticationRepository()) }
    }

    var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: self.serverUrl()) }
            .singleton
    }

    var usersRepository: Factory<UsersRepository> {
        self { buildUsersRepository(url: self.serverUrl(), authenticationProvider: self.authenticationRepository()) }
            .singleton
    }
}
