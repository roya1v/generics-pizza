import ComposableArchitecture
import Factory
import Testing
import Foundation

@testable import GenericsCore
@testable import AuthLogic

@MainActor
struct CreateAccountTests {
    @Test
    func createAccountWithBadInput() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: CreateAccountFeature.State()) {
            CreateAccountFeature()
        }

        await store.send(.createAccountTapped) {
            $0.errorMessage = "Fill out email and password!"
        }
        #expect(authRepository.createAccountEmailPasswordConfirmPasswordCalled == false)
    }

    @Test
    func createAccountWithGoodResponse() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: CreateAccountFeature.State()) {
            CreateAccountFeature()
        }

        let mockEmail = "test@test.test"
        let mockPassword = "test123"

        await store.send(.binding(.set(\.email, mockEmail))) {
            $0.email = mockEmail
        }
        await store.send(.binding(.set(\.password, mockPassword))) {
            $0.password = mockPassword
        }
        await store.send(.binding(.set(\.confirmPassword, mockPassword))) {
            $0.confirmPassword = mockPassword
        }
        await store.send(.createAccountTapped) {
            $0.isLoading = true
        }
        await store.receive(\.createAccountCompleted) {
            $0.isLoading = false
        }

        #expect(authRepository.createAccountEmailPasswordConfirmPasswordCalled == true)
        #expect(authRepository.createAccountEmailPasswordConfirmPasswordReceivedArguments?.email == mockEmail)
        #expect(authRepository.createAccountEmailPasswordConfirmPasswordReceivedArguments?.password == mockPassword)
    }

    @Test
    func createAccountWithBadResponse() async {
        let authRepository = AuthenticationRepositorySpy()
        Container.shared.authenticationRepository.register { authRepository }

        let store = TestStore(initialState: CreateAccountFeature.State()) {
            CreateAccountFeature()
        }

        let mockEmail = "test@test.test"
        let mockPassword = "test123"
        let mockError = TestError(message: "Mock error happend")

        authRepository.createAccountEmailPasswordConfirmPasswordClosure = { _, _, _ in
            throw mockError
        }

        await store.send(.binding(.set(\.email, mockEmail))) {
            $0.email = mockEmail
        }
        await store.send(.binding(.set(\.password, mockPassword))) {
            $0.password = mockPassword
        }
        await store.send(.binding(.set(\.confirmPassword, mockPassword))) {
            $0.confirmPassword = mockPassword
        }
        await store.send(.createAccountTapped) {
            $0.isLoading = true
        }

        await store.receive(\.createAccountCompleted) {
            $0.isLoading = false
            $0.errorMessage = mockError.localizedDescription
        }

        #expect(authRepository.createAccountEmailPasswordConfirmPasswordCalled == true)
        #expect(authRepository.createAccountEmailPasswordConfirmPasswordReceivedArguments?.email == mockEmail)
        #expect(authRepository.createAccountEmailPasswordConfirmPasswordReceivedArguments?.password == mockPassword)
    }
}
