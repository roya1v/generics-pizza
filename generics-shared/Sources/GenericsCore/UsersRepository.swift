//
//  UsersRepository.swift
//
//
//  Created by Mike S. on 19/03/2024.
//

import Foundation
import Combine
import SharedModels
import SwiftlyHttp

public func buildUsersRepository(url: String) -> UsersRepository {
    UsersRepositoryImpl(baseURL: url)
}

public protocol UsersRepository {
    var authFactory: (() -> SwiftlyHttp.Authentication?)? { get set }
    func getAll() async throws -> [UserModel]
    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserAccess) async throws
}

final class UsersRepositoryImpl: UsersRepository {

    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - UsersRepository

    var authFactory: (() -> SwiftlyHttp.Authentication?)?

    func getAll() async throws -> [UserModel] {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .method(.get)
            .authentication({
                self.authFactory?()
            })
            .decode(to: [UserModel].self)
            .perform()
    }

    func updateAccessLevel(for user: UserModel, to newAccessLevel: UserAccess) async throws {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "user")
            .add(path: "\(user.id!)")
            .method(.put)
            .authentication({
                self.authFactory?()
            })
            .body(newAccessLevel)
            .perform()
    }
}
