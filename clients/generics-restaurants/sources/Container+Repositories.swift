import Factory
import Foundation
import GenericsCore
import AuthLogic

extension Container {
    var orderRestaurantRepository: Factory<OrderRestaurantRepository> {
        self {
            buildOrderRestaurantRepository(
                url: self.serverUrl(),
                authenticationProvider: self.authenticationRepository())
        }
        .singleton
    }

    var menuRepository: Factory<MenuRepository> {
        self {
            buildMenuRepository(
                url: self.serverUrl(),
                authenticationProvider: self.authenticationRepository())
        }
    }

    var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: self.serverUrl()) }
            .singleton
    }

    var usersRepository: Factory<UsersRepository> {
        self {
            buildUsersRepository(
                url: self.serverUrl(), authenticationProvider: self.authenticationRepository())
        }
        .singleton
    }
}
