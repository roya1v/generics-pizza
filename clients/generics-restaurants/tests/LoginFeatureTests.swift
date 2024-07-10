//
//  LoginFeatureTests.swift
//  GenericsRestaurantsTests
//
//  Created by Mike S. on 10/07/2024.
//

import XCTest
@testable import clients_generics_restaurants_generics_restaurants
import ComposableArchitecture

class LoginFeatureTests: XCTestCase {
    @MainActor
    func testInput() async {
        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }
        
        await store.send(.sendEmail("mock-email")) {
            $0.email = "mock-email"
        }
        
        await store.send(.sendPassword("mock-password")) {
            $0.password = "mock-password"
        }
    }
}

