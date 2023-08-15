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

func buildAuthenticationRepository(url: String) -> AuthenticationRepository {
    AuthenticationRepositoryImpl(baseURL: url)
}

func mockAuthenticationRepository() -> AuthenticationRepository {
    AuthenticationRepositoryMck()
}

enum AuthenticationState {
    case loggedIn
    case loggedOut
}

protocol AuthenticationRepository: AuthorizationDelegate {
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

        UserDefaults.standard.set(response.value, forKey: "auth-token")

        stateSubject.send(.loggedIn)
    }

    func reload() {
        if let _ = UserDefaults.standard.string(forKey: "auth-token") {
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
        UserDefaults.standard.set(nil, forKey: "auth-token")
        stateSubject.send(.loggedOut)
    }

    func getAuthorization() throws -> SwiftlyHttp.Authorization {
        guard let token = UserDefaults.standard.string(forKey: "auth-token") else {
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
