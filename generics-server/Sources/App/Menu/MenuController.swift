//
//  MenuController.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor

struct MenuController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let menu = routes.grouped("menu")
        menu.get(use: index)
        menu.grouped(UserToken.authenticator()).post(use: create)
    }

    func index(req: Request) async throws -> [MenuEntry] {
        try await MenuEntry.query(on: req.db).all()
    }

    func create(req: Request) async throws -> MenuEntry {
        try req.auth.require(User.self)
        let entry = try req.content.decode(MenuEntry.self)
        try await entry.save(on: req.db)
        return entry
    }
}

