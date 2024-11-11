import Combine
import Foundation
import SharedModels
import SwiftlyHttp

public func buildUsersRepository(url: String, authenticationProvider: some AuthenticationProvider) -> UsersRepository {
    UsersRepositoryImpl(baseURL: url, authenticationProvider: authenticationProvider)
}

public protocol UsersRepository {
    func getAll() async throws -> [UserModel]
    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserModel.AccessLevel) async throws
    func delete(user: UserModel) async throws
}

final class UsersRepositoryImpl: UsersRepository {

    private let baseURL: String
    private let authenticationProvider: AuthenticationProvider

    init(baseURL: String, authenticationProvider: some AuthenticationProvider) {
        self.baseURL = baseURL
        self.authenticationProvider = authenticationProvider
    }

    // MARK: - UsersRepository

    func getAll() async throws -> [UserModel] {
        try await request()
            .method(.get)
            .decode(to: [UserModel].self)
            .perform()
    }

    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserModel.AccessLevel) async throws {
        try await request()
            .add(path: "\(user.id!)")
            .method(.put)
            .body(newAccessLevel)
            .perform()
    }

    func delete(user: UserModel) async throws {
        try await request()
            .add(path: "\(user.id!)")
            .method(.delete)
            .perform()
    }

    private func request() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .authentication {
                try? self.authenticationProvider.getAuthentication()
            }
    }
}
