//
//  MenuController.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor
import GenericsModels

struct MenuController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let menu = routes.grouped("menu")
        menu.get(use: index)
        menu.grouped(UserToken.authenticator()).post(use: create)
    }

    func index(req: Request) async throws -> [MenuItem] {
        try await MenuEntry
            .query(on: req.db)
            .all()
            .map { $0.getContent() }
    }

    func create(req: Request) async throws -> MenuItem {
        try req.auth.require(User.self)
        let entry = try req.content.decode(MenuItem.self)
        try await entry.getModel().save(on: req.db)
        return entry
    }
}
