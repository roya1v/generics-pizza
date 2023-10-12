//
//  AuthenticationService.swift
//  GenericsHelpers
//
//  Created by Mike S. on 23/09/2023.
//

import Foundation
import SwiftlyHttp

public final class AuthenticationService {

    private struct LoginResponse: Decodable {
        let value: String
    }

    private let baseURL: String

    public init(baseURL: String) {
        self.baseURL = baseURL
    }

    public func login(email: String, password: String) async throws -> String {
        let response = try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "login")
            .authorization(.basic(login: email, password: password))
            .method(.post)
            .decode(to: LoginResponse.self)
            .perform()

        return response.value
    }

    public func signOut(_ token: String) async throws {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "signout")
            .authorization({
                .bearer(token: token)
            })
            .method(.post)
            .perform()
    }
}
