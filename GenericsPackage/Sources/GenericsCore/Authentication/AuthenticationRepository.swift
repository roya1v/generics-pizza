import Combine
import Foundation
import SharedModels
import Spyable
import SwiftlyHttp
import Factory

extension Container {
    public var authenticationRepository: Factory<AuthenticationRepository> {
        self { AuthenticationRepositoryImpl() }
            .singleton
    }
}

@Spyable
public protocol AuthenticationRepository: AuthenticationProvider {
    func login(email: String, password: String) async throws
    func createAccount(email: String, password: String, confirmPassword: String) async throws
    func checkState() async -> UserModel?
    func signOut() async throws
    func getMe() async throws -> UserModel
    // https://github.com/Matejkob/swift-spyable/issues/47
    func getAuthentication() throws -> SwiftlyHttp.Authentication
}

final class AuthenticationRepositoryImpl: AuthenticationRepository {

    private let settingsService = LocalSettingsServiceImpl()
    private let authenticationService = AuthenticationService()

    // MARK: - AuthenticationRepository

    func login(email: String, password: String) async throws {
        let token = try await authenticationService.login(email: email, password: password)

        settingsService.setAuthToken(token)
    }

    func createAccount(email: String, password: String, confirmPassword: String) async throws {
        _ = try await authenticationService.createAccount(
            email: email,
            password: password,
            confirmPassword: confirmPassword)

        try await login(email: email, password: password)
    }

    func checkState() async -> UserModel? {
        guard settingsService.getAuthToken() != nil else {
            return nil
        }
        return try? await getMe()
    }

    func signOut() async throws {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }
        try await authenticationService.signOut(token)
        settingsService.resetAuthToken()
    }

    func getMe() async throws -> UserModel {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }
        return try await authenticationService.getMe(token)
    }

    func getAuthentication() throws -> SwiftlyHttp.Authentication {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }

        return .bearer(token: token)
    }
}
