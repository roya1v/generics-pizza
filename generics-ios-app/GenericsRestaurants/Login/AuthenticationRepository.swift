//
//  AuthenticationRepository.swift
//  GenericsRestaurants
//
//  Created by Mike Shevelinsky on 15/02/2023.
//

import Foundation
import Factory
import Combine

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

    func login(email: String, password: String) async throws {

        let token = String(format: "%@:%@", email, password).data(using: .utf8)!.base64EncodedData()

        var request = URLRequest(url: URL(string: baseURL + "/auth/login")!)
        request.setValue("Basic \(String(data: token, encoding: .utf8)!)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let stuff = try await URLSession.shared.data(for: request)
        let respone = try JSONDecoder().decode(LoginResponse.self, from: stuff.0)

        print(respone.value)
        stateSubject.send(.loggedIn)
    }
}

final class AuthenticationRepositoryMck: AuthenticationRepository {
    var state: AnyPublisher<AuthenticationState, Never> = PassthroughSubject().eraseToAnyPublisher()

    func login(email: String, password: String) async throws {
        return
    }
}
