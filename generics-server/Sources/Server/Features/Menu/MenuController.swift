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
            item.group("image") { image in
                image.get(use: getImage)
                image.grouped(UserTokenEntry.authenticator()).post(use: setImage)
                image.grouped(UserTokenEntry.authenticator()).delete(use: deleteImage)
            }
            item.grouped(UserTokenEntry.authenticator()).delete(use: delete)
        }
    }

    /// Get all menu items.
    func index(req: Request) async throws -> [MenuItem] {
        try await MenuEntry
            .query(on: req.db)
            .all()
            .toSharedModels()
    }

    /// Create a new menu item.
    func create(req: Request) async throws -> MenuItem {
        try req.requireEmployeeOrAdminUser()
        let entry = try req.content.decode(MenuItem.self).toEntry()
        try await entry.create(on: req.db)
        return entry.toSharedModel()
    }

    /// Delete a menu item.
    func delete(req: Request) async throws -> HTTPStatus {
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        let id = menuItem.id!

        if let imageData = try? await req.s3.getObject(.init(bucket: "menu-images", key: "\(id).jpeg")) {
            _ = try await req.s3.deleteObject(.init(bucket: "menu-images", key: "\(id).jpeg"))
        }

        try await menuItem.delete(on: req.db)
        return .ok
    }

    /// Get the menu item image.
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

    /// Set the menu item image.
    func setImage(req: Request) async throws -> HTTPResponseStatus {
        try req.requireEmployeeOrAdminUser()
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db),
              let id = menuItem.id else {
            throw Abort(.notFound)
        }

        guard req.headers.contentType == .jpeg else {
            throw Abort(.badRequest, reason: "Content must be jpeg")
        }

        _ = try await req.s3.putObject(.init(body: .byteBuffer(req.body.data!),
                                             bucket: "menu-images",
                                             key: "\(id).jpeg"))
        return .ok
    }

    /// Delete the menu item image.
    func deleteImage(req: Request) async throws -> MenuItem {
        throw Abort(.notImplemented)
    }
}
