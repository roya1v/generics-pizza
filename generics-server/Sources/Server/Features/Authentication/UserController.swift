//
//  UserController.swift
//
//
//  Created by Mike S. on 19/11/2023.
//

import Fluent
import Vapor

import SharedModels

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let user = routes.grouped("user").grouped(UserTokenEntry.authenticator())

        user.get(use: index)
        user.group(":userID") { user in
            user.delete(use: deleteUser)
            user.put(use: updateUserAccess)
        }
    }

    /// Get all users
    func index(req: Request) async throws -> [UserEntry] {
        try req.requireAdminUser()
        return try await UserEntry
            .query(on: req.db)
            .all()
    }

    /// Delete a user
    func deleteUser(req: Request) async throws -> HTTPStatus {
        guard let user = try await UserEntry.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }

        if let id = user.id {
            let tokens = try await UserTokenEntry
                .query(on: req.db)
                .filter(\.$user.$id == user.id!)
                .all()
            try await tokens.delete(on: req.db)
        }

        try await user.delete(on: req.db)
        return .ok
    }

    /// Update a user's access
    func updateUserAccess(req: Request) async throws -> UserEntry {
        try req.requireAdminUser()
        guard let user = try await UserEntry.find(req.parameters.get("userID"), on: req.db) else {
            throw Abort(.notFound)
        }
        let newAccess = try req.content.decode(UserModel.AccessLevel.self)

        let newAccessEntry: AccessLevel = switch(newAccess) {
        case .client:
                .client
        case .employee:
                .employee
        case .admin:
                .admin
        }

        user.access = newAccessEntry

        try await user.update(on: req.db)
        return user
    }
}
