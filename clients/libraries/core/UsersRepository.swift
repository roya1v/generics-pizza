import Combine
import Foundation
import SharedModels
import SwiftlyHttp

public func buildUsersRepository(url: String, authenticationProvider: some AuthenticationProvider)
    -> UsersRepository
{
    UsersRepositoryImpl(baseURL: url, authenticationProvider: authenticationProvider)
}

public protocol UsersRepository {
    func getAll() async throws -> [UserModel]
    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserModel.AccessLevel)
        async throws
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
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .method(.get)
            .authentication({
                try? self.authenticationProvider.getAuthentication()
            })
            .decode(to: [UserModel].self)
            .perform()
    }

    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserModel.AccessLevel)
        async throws
    {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .add(path: "\(user.id!)")
            .method(.put)
            .authentication({
                try? self.authenticationProvider.getAuthentication()
            })
            .body(newAccessLevel)
            .perform()
    }

    func delete(user: UserModel) async throws {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .add(path: "\(user.id!)")
            .method(.delete)
            .authentication({
                try? self.authenticationProvider.getAuthentication()
            })
            .perform()
    }
}
