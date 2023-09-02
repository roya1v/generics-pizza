//
//  MenuController.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor
import SharedModels
import PathKit

struct MenuController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let menu = routes.grouped("menu")
        menu.get(use: index)
        menu.grouped(UserTokenEntry.authenticator()).post(use: create)
        menu.group(":itemID") { item in
            item.get(use: getImage)
            item.grouped(UserTokenEntry.authenticator()).post(use: setImage)
        }
    }

    /// Get all menu items
    func index(req: Request) async throws -> [MenuItem] {
        try await MenuEntry
            .query(on: req.db)
            .all()
            .map { $0.toSharedModel() }
    }

    /// Get image for a menu item
    func getImage(req: Request) async throws -> Response {
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db),
              let id = menuItem.id else {
            throw Abort(.notFound)
        }

        let imageData = try await req.s3.getObject(.init(bucket: "menu-images", key: "\(id).jpeg"))

        let resp = Response()
        resp.body = Response.Body(data: (imageData.body?.asData()!)!)
        resp.headers.contentType = .jpeg

        return resp
    }

    /// Set image for menu item
    func setImage(req: Request) async throws -> HTTPResponseStatus {
        try req.auth.require(UserEntry.self)
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db),
              let id = menuItem.id else {
            throw Abort(.notFound)
        }

        guard req.headers.contentType == .jpeg else {
            throw Abort(.badRequest, reason: "Content must be jpeg")
        }

        _ = try await req.s3.putObject(.init(body: .byteBuffer(req.body.data!), bucket: "menu-images", key: "\(id).jpeg"))
        return .notImplemented
    }

    /// Create a menu item
    func create(req: Request) async throws -> MenuItem {
        try req.auth.require(UserEntry.self)
        let entry = try req.content.decode(MenuItem.self)
        try await entry.toEntry().save(on: req.db)
        return entry
    }
}
