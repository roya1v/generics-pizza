//
//  MenuViewModelTests.swift
//  GenericsAppTests
//
//  Created by Mike S. on 27/09/2023.
//

import XCTest
import Factory
@testable import GenericsApp
@testable import GenericsCore
import SharedModels
import Combine
import GenericsUI

@MainActor
final class MenuViewModelTests: XCTestCase {

    var sut: MenuViewModel!
    var mockMenuRepository: MenuRepositorySpy!
    var cancellable = Set<AnyCancellable>()

    override func setUp() {
        mockMenuRepository = MenuRepositorySpy()
        Container.shared.menuRepository.register {
            self.mockMenuRepository
        }

        sut = MenuViewModel()
    }

    func testFetch() {
        let expectation = XCTestExpectation(description: "All correct states occured")
        let mockItems = [MenuItem(id: nil, title: "mock", description: "mock", price: 0)]
        mockMenuRepository.fetchMenuClosure = {
            return mockItems
        }
        var oldState: ViewState?
        sut.fetch()
        sut.$state.sink { newState in
            switch oldState {
            case .loading:
                XCTAssertEqual(newState, .ready)
                XCTAssertEqual(self.sut.items, mockItems)
                expectation.fulfill()
            case .ready:
                XCTFail("There shouldn't be a new state after ready")
            case .error:
                XCTFail("View state should have stayed ready")
            case nil:
                XCTAssertEqual(newState, .loading)
            }
            oldState = newState

        }
        .store(in: &cancellable)
        wait(for: [expectation])
    }

    func testFetchWithError() {
        let expectation = XCTestExpectation(description: "All correct states occured")
        mockMenuRepository.fetchMenuClosure = {
            throw NSError(domain: "", code: 1)
        }
        var oldState: ViewState?
        sut.fetch()
        sut.$state.sink { newState in
            switch oldState {
            case .loading:
                XCTAssertEqual(newState, .error)
                expectation.fulfill()
            case .ready:
                XCTFail("View state should have stayed error")
            case .error:
                XCTFail("There shouldn't be a new state after error")
            case nil:
                XCTAssertEqual(newState, .loading)
            }
            oldState = newState

        }
        .store(in: &cancellable)
        wait(for: [expectation])
    }
}
