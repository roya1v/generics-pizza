import Foundation
import SharedModels
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
        let response: LoginResponse = try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "login")
            .authentication(.basic(login: email, password: password))
            .method(.post)
            .decode(to: LoginResponse.self)
            .perform()

        return response.value
    }

    public func createAccount(email: String, password: String, confirmPassword: String) async throws
        -> UserModel
    {
        let response: UserModel = try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "user")
            .body(
                UserModel.Create(
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword)
            )
            .method(.post)
            .decode(to: UserModel.self)
            .perform()

        return response
    }

    public func signOut(_ token: String) async throws {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "signout")
            .authentication(.bearer(token: token))
            .method(.post)
            .perform()
    }

    public func getMe(_ token: String) async throws -> UserModel {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "auth")
            .add(path: "user")
            .authentication(.bearer(token: token))
            .method(.get)
            .decode(to: UserModel.self)
            .perform()
    }
}
