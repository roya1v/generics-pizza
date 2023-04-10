//
//  MenuController.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor
import GenericsModels
import PathKit

struct MenuController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let menu = routes.grouped("menu")
        menu.get(use: index)
        menu.grouped(UserToken.authenticator()).post(use: create)
        menu.group(":itemID") { item in
            item.get(use: image)
        }
    }

    func index(req: Request) async throws -> [MenuItem] {
        try await MenuEntry
            .query(on: req.db)
            .all()
            .map { $0.getContent() }
    }

    func image(req: Request) async throws -> Response {
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db),
              let id = menuItem.id else {
            throw Abort(.notFound)
        }

        let imageData = try (Path.current + "images" + "\(id.uuidString).png").read()
        let resp = Response()
        resp.body = Response.Body(data: imageData)

        return resp
    }

    func create(req: Request) async throws -> MenuItem {
        try req.auth.require(User.self)
        let entry = try req.content.decode(MenuItem.self)
        try await entry.getModel().save(on: req.db)
        return entry
    }
}
