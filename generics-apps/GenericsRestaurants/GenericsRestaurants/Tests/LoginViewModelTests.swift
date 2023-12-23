//
//  LoginViewModelTests.swift
//  GenericsRestaurantsTests
//
//  Created by Mike S. on 19/12/2023.
//

import XCTest
@testable import GenericsRestaurants
@testable import GenericsCore
import Factory
import Combine

@MainActor
final class LoginViewModelTests: XCTestCase {

    var sut: LoginViewModel!
    var spyAuthenticationRepository: AuthenticationRepositorySpy!

    override func setUp() {
        spyAuthenticationRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { self.spyAuthenticationRepository }
        sut = LoginViewModel()
    }

    func testLoginWithCreds() throws {
        let goodEmail = "test@test.test"
        let goodPassword = "Qwerty!23"
        let expectation = XCTestExpectation()

        spyAuthenticationRepository.loginEmailPasswordClosure = { (email, password) in
            XCTAssertEqual(email, goodEmail)
            XCTAssertEqual(password, goodPassword)
            expectation.fulfill()
        }

        sut.email = goodEmail
        sut.password = goodPassword

        sut.login()
        XCTAssertEqual(sut.state, .loading)

        wait(for: [expectation])
    }

    func testLoginWithNoCreds() throws {
        let expectation = XCTestExpectation()
        var cancellable = Set<AnyCancellable>()

        sut.$state.sink { state in
            if case .error = state {
                expectation.fulfill()
            }
        }
        .store(in: &cancellable)

        spyAuthenticationRepository.loginEmailPasswordClosure = { (email, password) in
            XCTFail("Authentication repository should be called with invalid credentials")
        }

        sut.login()
        wait(for: [expectation])
    }
}
