//
//  AuthenticationRepository.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/02/2023.
//

import Foundation
import Factory
import Combine
import SwiftlyHttp

public func buildAuthenticationRepository(url: String) -> AuthenticationRepository {
    AuthenticationRepositoryImpl(baseURL: url)
}

public func mockAuthenticationRepository() -> AuthenticationRepository {
    AuthenticationRepositoryMck()
}

public enum AuthenticationState {
    case loggedIn
    case loggedOut
}

public protocol AuthenticationRepository: AuthorizationDelegate {
    var state: AnyPublisher<AuthenticationState, Never> { get }
    func login(email: String, password: String) async throws
    func reload()
    func signOut() async throws
}

final class AuthenticationRepositoryImpl: AuthenticationRepository {

    private struct LoginResponse: Decodable {
        let value: String
    }

    private let baseURL: String
    private let stateSubject = PassthroughSubject<AuthenticationState, Never>()

    private let settingsService = LocalSettingsServiceImpl()

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - AuthenticationRepository

    var state: AnyPublisher<AuthenticationState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    func login(email: String, password: String) async throws {
        let response = try await SwiftlyHttp(baseURL: "http://localhost:8080")!
            .add(path: "auth")
            .add(path: "login")
            .authorization(.basic(login: email, password: password))
            .method(.post)
            .decode(to: LoginResponse.self)
            .perform()

        settingsService.setAuthToken(response.value)

        stateSubject.send(.loggedIn)
    }

    func reload() {
        if let _ = settingsService.getAuthToken() {
            stateSubject.send(.loggedIn)
        } else {
            stateSubject.send(.loggedOut)
        }
    }

    func signOut() async throws {
        try await SwiftlyHttp(baseURL: "http://localhost:8080")!
            .add(path: "auth")
            .add(path: "signout")
            .authorizationDelegate(self)
            .method(.post)
            .perform()
        settingsService.resetAuthToken()
        stateSubject.send(.loggedOut)
    }

    func getAuthorization() throws -> SwiftlyHttp.Authorization {
        guard let token = settingsService.getAuthToken() else {
            fatalError()
        }

        return .bearer(token: token)
    }
}

final class AuthenticationRepositoryMck: AuthenticationRepository {
    var state: AnyPublisher<AuthenticationState, Never> = PassthroughSubject().eraseToAnyPublisher()

    func login(email: String, password: String) async throws {
    }

    func reload() {
    }

    func getAuthorization() throws -> SwiftlyHttp.Authorization {
        fatalError()
    }

    func signOut() async throws {
    }
}
