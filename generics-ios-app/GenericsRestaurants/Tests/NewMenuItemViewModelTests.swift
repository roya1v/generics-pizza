//
//  NewMenuItemViewModelTests.swift
//  GenericsRestaurantsTests
//
//  Created by Mike S. on 19/12/2023.
//

import XCTest
@testable import GenericsRestaurants
@testable import GenericsCore
import Factory
import SharedModels

@MainActor
final class NewMenuItemViewModelTests: XCTestCase {

    var sut: NewMenuItemViewModel!
    var spyMenuRepository: MenuRepositorySpy!
    var spyAuthenticationRepository: AuthenticationRepositorySpy!
    
    override func setUp() {
        spyMenuRepository = MenuRepositorySpy()
        Container.shared.menuRepository.register { self.spyMenuRepository }
        sut = NewMenuItemViewModel()
    }

    func testValidCreation() {
        let mockMenuItem = MenuItem(id: UUID(), title: "Mock", description: "Mock desciption", price: 123)
        let expectation = XCTestExpectation()
        spyMenuRepository.createItemClosure = { item in
            XCTAssertEqual(mockMenuItem.title, item.title)
            XCTAssertEqual(mockMenuItem.description, item.description)
            XCTAssertEqual(mockMenuItem.price, item.price)
            XCTAssertNil(item.id)
            expectation.fulfill()
            return mockMenuItem
        }

        sut.title = mockMenuItem.title
        sut.description = mockMenuItem.description
        sut.price = Double(mockMenuItem.price) / 100.0
        sut.createMenuItem()

        wait(for: [expectation])
    }
}
