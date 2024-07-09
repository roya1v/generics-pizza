//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike S. on 02/02/2023.
//

import Foundation
import SharedModels
import clients_libraries_SwiftlyHttp
import Spyable
import Factory

extension Container {
    public var menuRepository: Factory<MenuRepository> {
        self { MenuRepositoryImp(baseURL: url, authenticationProvider: nil) }
            .onPreview { MenuRepositoryPreview() }
    }
}

// Kept temporarily for restaurant app
public func buildMenuRepository(url: String, authenticationProvider: AuthenticationProvider? = nil) -> MenuRepository {
    MenuRepositoryImp(baseURL: url, authenticationProvider: authenticationProvider)
}

@Spyable
public protocol MenuRepository {
    func fetchMenu() async throws -> [MenuItem]
    func create(item: MenuItem) async throws -> MenuItem
    func delete(item: MenuItem) async throws
    func imageUrl(for item: MenuItem) -> URL?
    func setImage(from localUrl: URL, for item: MenuItem) async throws
}

enum MenuRepositoryError: Error {
    case invalidFile
}

final class MenuRepositoryImp: MenuRepository {

    private let baseURL: String
    private let authenticationProvider: AuthenticationProvider?

    init(baseURL: String, authenticationProvider: AuthenticationProvider?) {
        self.baseURL = baseURL
        self.authenticationProvider = authenticationProvider
    }

    // MARK: - MenuRepository

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
                try? self.authenticationProvider?.getAuthentication()
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
                try? self.authenticationProvider?.getAuthentication()
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
                try? self.authenticationProvider?.getAuthentication()
            })
            .perform()
    }
}

private class MenuRepositoryPreview: MenuRepository {
    func fetchMenu() async throws -> [SharedModels.MenuItem] {
        [.init(id: nil, title: "Preview pizza", description: "Pizza for previews", price: 999)]
    }
    
    func create(item: SharedModels.MenuItem) async throws -> SharedModels.MenuItem {
        fatalError()
    }
    
    func delete(item: SharedModels.MenuItem) async throws {
        fatalError()
    }
    
    func imageUrl(for item: SharedModels.MenuItem) -> URL? {
        return nil
    }
    
    func setImage(from localUrl: URL, for item: SharedModels.MenuItem) async throws {
        fatalError()
    }
}
