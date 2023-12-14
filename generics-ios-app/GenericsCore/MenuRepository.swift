//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 02/02/2023.
//

import Foundation
import SharedModels
import SwiftlyHttp

public func buildMenuRepository(url: String) -> MenuRepository {
    MenuRepositoryImp(baseURL: url)
}

public func mockMenuRepository() -> MenuRepository {
    MenuRepositoryMck()
}

public protocol MenuRepository {
    func fetchMenu() async throws -> [MenuItem]
    func create(item: MenuItem) async throws -> MenuItem
    func delete(item: MenuItem) async throws
    var authFactory: (() -> SwiftlyHttp.Authentication?)? { get set }
    func imageUrl(for item: MenuItem) -> URL?
    func setImage(from localUrl: URL, for item: MenuItem) async throws
}

enum MenuRepositoryError: Error {
    case invalidFile
}

final class MenuRepositoryImp: MenuRepository {


    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    // MARK: - MenuRepository
    
    var authFactory: (() -> SwiftlyHttp.Authentication?)?

    public func fetchMenu() async throws -> [MenuItem] {
         return try await getRequest()
            .method(.get)
            .decode(to: [MenuItem].self)
            .perform()
    }

    public func create(item: MenuItem) async throws -> MenuItem {
        try await getRequest()
            .method(.post)
            .authentication({
                self.authFactory?()
            })
            .body(item)
            .decode(to: MenuItem.self)
            .perform()
    }

    func imageUrl(for item: SharedModels.MenuItem) -> URL? {
        guard let idString = item.id?.uuidString else {
            return nil
        }
        return URL(string: "\(baseURL)/menu/\(idString)/image")
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "menu")
    }
    
    func setImage(from localUrl: URL, for item: MenuItem) async throws {
        guard localUrl.isFileURL else {
            throw MenuRepositoryError.invalidFile
        }
        let imageData = try Data(contentsOf: localUrl)
        try await getRequest()
            .method(.post)
            .add(path: item.id!.uuidString)
            .add(path: "image")
            .authentication({
                self.authFactory?()
            })
            .setHeader("Content-Type", to: "image/jpeg")
            .body(imageData)
            .perform()
    }

    func delete(item: MenuItem) async throws {
        try await getRequest()
            .method(.delete)
            .add(path: item.id!.uuidString)
            .authentication({
                self.authFactory?()
            })
            .perform()
    }
}

final class MenuRepositoryMck: MenuRepository {

    var authFactory: (() -> SwiftlyHttp.Authentication?)?
    var fetchMenuImplementation: (() async throws -> [MenuItem]) = {
        [.init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", price: 100),
         .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 100),
         .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", price: 100)
        ]
    }
    func fetchMenu() async throws -> [MenuItem] {
        try await fetchMenuImplementation()
    }

    func create(item: MenuItem) async throws -> MenuItem {
         .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 100)
    }

    func imageUrl(for item: MenuItem) -> URL? {
        return nil
    }
    
    func setImage(from localUrl: URL, for item: MenuItem) async throws {
    }
    
    func delete(item: MenuItem) async throws {

    }
}
