//
//  AuthenticationController.swift
//  
//
//  Created by Mike Shevelinsky on 13/02/2023.
//

import Fluent
import Vapor

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("user", use: create)

        auth.grouped(UserEntry.authenticator()).post("login", use: login)

        let authenticated = auth.grouped(UserTokenEntry.authenticator())
        authenticated.get("user", use: me)
        authenticated.post("signout", use: signOut)
    }

    /// Create new user
    func create(req: Request) async throws -> UserEntry {
        let create = try req.content.decode(UserEntry.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try UserEntry(
            email: create.email,
            passwordHash: Bcrypt.hash(create.password),
            access: .client
        )
        try await user.save(on: req.db)
        return user
    }

    /// Login and get an auth token
    func login(req: Request) async throws -> UserTokenEntry {
        let user = try req.requireAnyUser()
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    /// Check current user
    func me(req: Request) async throws -> UserEntry {
        try req.requireAnyUser()
    }

    /// Sign out deleting auth token
    func signOut(req: Request) async throws -> HTTPResponseStatus {
        let user = try req.requireAnyUser()
        if let id = user.id,
           let token = try await
            UserTokenEntry.query(on: req.db)
                .with(\.$user)
                .filter(\.$user.$id == id)
                .first() {
            try await token.delete(on: req.db)
            return .ok
        }
        return .internalServerError
    }
}
