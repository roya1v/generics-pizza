import Fluent
import Vapor
import SharedModels
import PathKit

struct MenuController: RouteCollection {

    private let imagesBucket = "menu-images"

    func boot(routes: RoutesBuilder) throws {
        let menu = routes.grouped("menu")

        let authenticatedMenu = menu.grouped(UserTokenEntry.authenticator())
        authenticatedMenu.get(use: index)
        authenticatedMenu.post(use: create)
        authenticatedMenu.put(use: update)

        menu.group(":itemID") { item in
            item.group("image") { image in
                image.get(use: getImage)

                let authenticated = image.grouped(UserTokenEntry.authenticator())
                authenticated.post(use: setImage)
                authenticated.delete(use: deleteImage)
            }
            item.grouped(UserTokenEntry.authenticator()).delete(use: delete)
        }

        let categories = menu.grouped("categories")

        let authenticatedCategories = categories.grouped(UserTokenEntry.authenticator())
        authenticatedCategories.get(use: indexCategories)
        authenticatedCategories.post(use: createCategory)
        authenticatedCategories.put(use: updateCategory)

        categories.group(":itemID") { item in
            item.grouped(UserTokenEntry.authenticator()).delete(use: deleteCategory)
        }
    }

    /// Get all menu items.
    func index(req: Request) async throws -> [MenuItem] {
        var query = MenuEntry
            .query(on: req.db)
            .with(\.$category)

        if let category: UUID = req.query["category"] {
            query
                .filter(\.$category.$id == category)
        }

        if let showHidden: Bool = req.query["showHidden"],
           showHidden {
            try req.requireEmployeeOrAdminUser()
            return try await query
                .all()
                .toSharedModels()
        }
        return try await query
            .filter(\.$isHidden == false)
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

    /// Update a menu item.
    func update(req: Request) async throws -> MenuItem {
        try req.requireEmployeeOrAdminUser()
        let model = try req.content.decode(MenuItem.self)
        guard let entry = try await MenuEntry.find(model.id, on: req.db) else {
            throw Abort(.notFound)
        }
        entry.title = model.title
        entry.description = model.description
        entry.price = model.price
        entry.isHidden = model.isHidden
        entry.$category.id = model.category?.id
        try await entry.update(on: req.db)
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

        do {
            let imageData = try await req.s3.getObject(.init(bucket: imagesBucket, key: "\(id).png"))
            let resp = Response()
            resp.body = Response.Body(data: (imageData.body?.asData()!)!)
            resp.headers.contentType = .jpeg

            return resp
        } catch {
            throw Abort(.notFound, reason: "No image for this item exists.")
        }
    }

    /// Set the menu item image.
    func setImage(req: Request) async throws -> HTTPResponseStatus {
        try req.requireEmployeeOrAdminUser()
        guard let menuItem = try await MenuEntry.find(req.parameters.get("itemID"), on: req.db),
              let id = menuItem.id else {
            throw Abort(.notFound)
        }

        let filename: String

        switch req.headers.contentType {
        case .jpeg:
            filename = "\(id).jpeg"
        case .png:
            filename = "\(id).png"
        default:
            throw Abort(.badRequest, reason: "Content must be jpeg")
        }

        req.logger.debug("Putting object into s3 bucket - \(imagesBucket), key - \(filename)")
        _ = try await req.s3.putObject(.init(body: .byteBuffer(req.body.data!),
                                             bucket: imagesBucket,
                                             key: filename))
        return .ok
    }

    /// Delete the menu item image.
    func deleteImage(req: Request) async throws -> MenuItem {
        throw Abort(.notImplemented)
    }

    /// Get all menu categories.
    func indexCategories(req: Request) async throws -> [MenuItem.Category] {
        return try await CategoryEntry
            .query(on: req.db)
            .all()
            .toSharedModels()
    }

    /// Create a new menu category.
    func createCategory(req: Request) async throws -> MenuItem.Category {
        try req.requireEmployeeOrAdminUser()
        let entry = try req.content.decode(MenuItem.Category.self).toEntry()
        try await entry.create(on: req.db)
        return entry.toSharedModel()
    }

    /// Update a menu category.
    func updateCategory(req: Request) async throws -> MenuItem.Category {
        try req.requireEmployeeOrAdminUser()
        let model = try req.content.decode(MenuItem.Category.self)
        guard let entry = try await CategoryEntry.find(model.id, on: req.db) else {
            throw Abort(.notFound)
        }
        entry.name = model.name
        try await entry.update(on: req.db)
        return entry.toSharedModel()
    }

    /// Delete a menu category.
    func deleteCategory(req: Request) async throws -> HTTPStatus {
        guard let category = try await CategoryEntry.find(req.parameters.get("itemID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await category.delete(on: req.db)
        return .ok
    }
}
