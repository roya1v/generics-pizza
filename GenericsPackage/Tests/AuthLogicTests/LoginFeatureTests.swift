import ComposableArchitecture
import Factory
import Testing
import Foundation

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

    @Test
    func loginWithGoodResponse() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        let mockEmail = "test@test.test"
        let mockPassword = "test123"

        await store.send(.binding(.set(\.email, mockEmail))) {
            $0.email = mockEmail
        }
        await store.send(.binding(.set(\.password, mockPassword))) {
            $0.password = mockPassword
        }
        await store.send(.loginTapped) {
            $0.isLoading = true
        }
        await store.receive(\.loginCompleted) {
            $0.isLoading = false
        }

        #expect(authRepository.loginEmailPasswordCalled == true)
        #expect(authRepository.loginEmailPasswordReceivedArguments?.email == mockEmail)
        #expect(authRepository.loginEmailPasswordReceivedArguments?.password == mockPassword)
    }

    @Test
    func loginWithBadResponse() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: LoginFeature.State()) {
            LoginFeature()
        }

        let mockEmail = "test@test.test"
        let mockPassword = "test123"
        let mockError = TestError(message: "Mock error happend")

        authRepository.loginEmailPasswordClosure = { _, _ in
            throw mockError
        }

        await store.send(.binding(.set(\.email, mockEmail))) {
            $0.email = mockEmail
        }
        await store.send(.binding(.set(\.password, mockPassword))) {
            $0.password = mockPassword
        }
        await store.send(.loginTapped) {
            $0.isLoading = true
        }

        await store.receive(\.loginCompleted) {
            $0.isLoading = false
            $0.errorMessage = mockError.localizedDescription
        }

        #expect(authRepository.loginEmailPasswordCalled == true)
        #expect(authRepository.loginEmailPasswordReceivedArguments?.email == mockEmail)
        #expect(authRepository.loginEmailPasswordReceivedArguments?.password == mockPassword)
    }
}

struct TestError: Error, LocalizedError {
    let message: String

    var errorDescription: String {
        message
    }
}
