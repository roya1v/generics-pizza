//
//  AuthenticationRepository.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 15/02/2023.
//

import Foundation
import Factory
import Combine
import GenericsHttp

extension Container {
    static let authenticationRepository = Factory(scope: .singleton) { AuthenticationRepositoryImpl() as AuthenticationRepository }
}

enum AuthenticationState {
    case loggedIn
    case loggedOut
}

protocol AuthenticationRepository {
    var state: AnyPublisher<AuthenticationState, Never> { get }
    func login(email: String, password: String) async throws
    func reload()
}

final class AuthenticationRepositoryImpl: AuthenticationRepository {

    private struct LoginResponse: Decodable {
        let value: String
    }

    var state: AnyPublisher<AuthenticationState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var stateSubject = PassthroughSubject<AuthenticationState, Never>()

    private let baseURL = "http://localhost:8080"

    func reload() {
        if let _ = UserDefaults.standard.string(forKey: "auth-token") {
            stateSubject.send(.loggedIn)
        } else {
            stateSubject.send(.loggedOut)
        }
    }

    func login(email: String, password: String) async throws {

        let response = try await GenericsHttp(baseURL: "http://localhost:8080")!
            .add(path: "auth")
            .add(path: "login")
            .authorization(.basic(login: email, password: password))
            .method(.post)
            .perform()

        let respone = try JSONDecoder().decode(LoginResponse.self, from: response.0)

        UserDefaults.standard.set(respone.value, forKey: "auth-token")

        stateSubject.send(.loggedIn)
    }
}

final class AuthenticationRepositoryMck: AuthenticationRepository {
    var state: AnyPublisher<AuthenticationState, Never> = PassthroughSubject().eraseToAnyPublisher()

    func login(email: String, password: String) async throws {
    }

    func reload() {
    }
}
