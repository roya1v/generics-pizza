import ComposableArchitecture
import Factory
import XCTest

@testable import GenericsCore
@testable import clients_generics_restaurants_generics_restaurants

class LoginFeatureTests: XCTestCase {

    var authRepositorySpy: AuthenticationRepositorySpy!
    var store: TestStoreOf<LoginFeature>!

    @MainActor
    override func setUp() async throws {
        authRepositorySpy = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register {
            self.authRepositorySpy
        }

        store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }
    }

    @MainActor
    func testLoginWithBadInput() async {
        store.exhaustivity = .off

        authRepositorySpy.loginEmailPasswordClosure = { _, _ in
            XCTFail("There shouldn't be a login attempt with invalid input")
        }

        await store.send(.loginTapped)
        XCTAssertNotNil(store.state.errorMessage)
    }

    @MainActor
    func testLoginInput() async {
        store.exhaustivity = .off
        let mockEmail = "test@test.test"
        let mockPassword = "test123"
        let expectation = XCTestExpectation()

        authRepositorySpy.loginEmailPasswordClosure = { email, password in
            XCTAssertEqual(email, mockEmail)
            XCTAssertEqual(password, mockPassword)
            expectation.fulfill()
        }

        await store.send(.binding(.set(\.email, mockEmail)))
        await store.send(.binding(.set(\.password, mockPassword)))
        await store.send(.loginTapped)

        await fulfillment(of: [expectation])
    }

    @MainActor
    func testLoginWithGoodResponse() async {
        store.exhaustivity = .off
        let mockEmail = "test@test.test"
        let mockPassword = "test123"

        await store.send(.binding(.set(\.email, mockEmail)))
        await store.send(.binding(.set(\.password, mockPassword)))
        await store.send(.loginTapped)

        await store.receive(\.loginCompleted)
        XCTAssertNil(store.state.errorMessage)
    }

    @MainActor
    func testLoginWithBadResponse() async {
        store.exhaustivity = .off
        let mockEmail = "test@test.test"
        let mockPassword = "test123"

        authRepositorySpy.loginEmailPasswordClosure = { _, _ in
            throw MockError()
        }

        await store.send(.binding(.set(\.email, mockEmail)))
        await store.send(.binding(.set(\.password, mockPassword)))
        await store.send(.loginTapped)

        await store.receive(\.loginCompleted)
        XCTAssertNotNil(store.state.errorMessage)
    }
}

struct MockError: Error, LocalizedError {
    let errorDescription: String? = "mock-error"
}
