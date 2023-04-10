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

        auth.grouped(User.authenticator()).post("login", use: login)

        let authenticated = auth.grouped(UserToken.authenticator())
        authenticated.get("user", use: me)
        authenticated.post("signout", use: signOut)
    }

    func create(req: Request) async throws -> User {
        let create = try req.content.decode(User.Create.self)
        guard create.password == create.confirmPassword else {
            throw Abort(.badRequest, reason: "Passwords did not match")
        }
        let user = try User(
            email: create.email,
            passwordHash: Bcrypt.hash(create.password),
            access: .client
        )
        try await user.save(on: req.db)
        return user
    }

    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    func me(req: Request) async throws -> User {
        try req.auth.require(User.self)
    }

    func signOut(req: Request) async throws -> HTTPResponseStatus {
        let user = try req.auth.require(User.self)
        if let id = user.id,
           let token = try await
            UserToken.query(on: req.db)
                .with(\.$user)
                .filter(\.$user.$id == id)
                .first() {
            try await token.delete(on: req.db)
            return .ok
        }
        return .internalServerError
    }
}
