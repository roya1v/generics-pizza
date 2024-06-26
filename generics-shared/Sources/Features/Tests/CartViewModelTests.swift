//
//  CartViewModelTests.swift
//  GenericsAppTests
//
//  Created by Mike S. on 15/08/2023.
//

import XCTest
import Factory
@testable import CustomerCart
@testable import GenericsCore

@MainActor
final class CartViewModelTests: XCTestCase {

    var sut: CartViewModel!
    var mockOrderRepository: OrderRepositoryMck!

    override func setUp() {
        mockOrderRepository = OrderRepositoryMck()
        Container.shared.orderRepository.register { self.mockOrderRepository }

        sut = CartViewModel()
    }

    func testExample() throws {
        mockOrderRepository.checkPriceImplementation = {
            return []
        }

        sut.fetch()
        XCTAssertEqual(sut.items.count, 3)

    }
}
