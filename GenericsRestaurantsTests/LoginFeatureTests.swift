import ComposableArchitecture
import Factory
import Testing

@testable import GenericsCore
@testable import AuthLogic

@MainActor
struct LoginFeatureTests {
    @Test
    func loginWithBadInput() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        await store.send(.loginTapped) {
            $0.errorMessage = "Fill out email and password!"
        }
        #expect(authRepository.loginEmailPasswordCalled == false)
    }
}

//class LoginFeatureTests: XCTestCase {
//
//    var authRepositorySpy: AuthenticationRepositorySpy!
//    var store: TestStoreOf<LoginFeature>!
//
//    @MainActor
//    func testLoginInput() async {
//        store.exhaustivity = .off
//        let mockEmail = "test@test.test"
//        let mockPassword = "test123"
//        let expectation = XCTestExpectation()
//
//        authRepositorySpy.loginEmailPasswordClosure = { email, password in
//            XCTAssertEqual(email, mockEmail)
//            XCTAssertEqual(password, mockPassword)
//            expectation.fulfill()
//        }
//
//        await store.send(.binding(.set(\.email, mockEmail)))
//        await store.send(.binding(.set(\.password, mockPassword)))
//        await store.send(.loginTapped)
//
//        await fulfillment(of: [expectation])
//    }
//
//    @MainActor
//    func testLoginWithGoodResponse() async {
//        store.exhaustivity = .off
//        let mockEmail = "test@test.test"
//        let mockPassword = "test123"
//
//        await store.send(.binding(.set(\.email, mockEmail)))
//        await store.send(.binding(.set(\.password, mockPassword)))
//        await store.send(.loginTapped)
//
//        await store.receive(\.loginCompleted)
//        XCTAssertNil(store.state.errorMessage)
//    }
//
//    @MainActor
//    func testLoginWithBadResponse() async {
//        store.exhaustivity = .off
//        let mockEmail = "test@test.test"
//        let mockPassword = "test123"
//
//        authRepositorySpy.loginEmailPasswordClosure = { _, _ in
//            throw MockError()
//        }
//
//        await store.send(.binding(.set(\.email, mockEmail)))
//        await store.send(.binding(.set(\.password, mockPassword)))
//        await store.send(.loginTapped)
//
//        await store.receive(\.loginCompleted)
//        XCTAssertNotNil(store.state.errorMessage)
//    }
//}

struct MockError: Error {
    let errorDescription: String? = "mock-error"
}
