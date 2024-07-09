//
//  MakeDriverOfferShortcut.swift
//  GenericsTester
//
//  Created by Mike S. on 12/10/2023.
//

import Foundation
import clients_libraries_GenericsCore
import SwiftlyHttp
import Combine

final class MakeDriverOfferShortcut: TestShortcut {
    let name = "Make driver offer"

    var menuRepository = buildMenuRepository(url: url)
    var orderRepository = buildOrderRepository(url: url)
    var orderRestaurantRepository = buildOrderRestaurantRepository(url: url)
    let authService = AuthenticationService(baseURL: url)

    var cancellable = Set<AnyCancellable>()

    var done = false

    func perform() async throws {
        print("Logging in with test user:")
        print("\t email: test@vapor.codes")
        print("\t password: secret42")
        let token = try await authService.login(email: "test@vapor.codes", password: "secret42")
        print("Log in succesfull, token: \(token)")
        let delegate = TemporaryAuthDelegate(token: token)
        orderRestaurantRepository.authDelegate = delegate

        print("Connecting as restaurant...")
        try await orderRestaurantRepository.getFeed()
            .sink { completion in
                fatalError()
            } receiveValue: { message in
                print("Restaurant: Received new message: \(message)")
                switch message {
                case .newOrder(let order):
                    Task {
                        print("Restaurant: Updating order state to make driver offer.")
                        try! await self.orderRestaurantRepository
                            .send(message: .update(orderId: order.id!, state: .readyForDelivery))
                        self.done = true
                    }
                }
            }
            .store(in: &cancellable)

        let items = try await menuRepository.fetchMenu()
        print("Found menu items: \(items)")

        orderRepository.add(item: items.first!)
        orderRepository.address = .init(coordinate: .init(latitude: 0, longitude: 0), details: "")
        print("Making order")
        let test = try await orderRepository.placeOrder()
        print("Order made!")

        while !done {
            print("Waiting for restaurant")
        }

        print("Signing out")
        try await authService.signOut(token)
    }
}

final class TemporaryAuthDelegate: AuthorizationDelegate {

    let token: String

    init(token: String) {
        self.token = token
    }

    func getAuthorization() throws -> SwiftlyHttp.Authorization {
        .bearer(token: token)
    }
}
