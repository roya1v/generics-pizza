//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation
import GenericsModels
import SwiftlyHttp

public func buildMenuRepository(url: String) -> MenuRepository {
    MenuRepositoryImp(baseURL: url)
}

public func mockMenuRepository() -> MenuRepository {
    MenuRepositoryMck()
}

public protocol MenuRepository {
    func fetchMenu() async throws -> [MenuItem]
    func create(item: MenuItem) async throws
    var authDelegate: AuthorizationDelegate? { get set}
}

final class MenuRepositoryImp: MenuRepository {

    private let baseURL: String

    public var authDelegate: AuthorizationDelegate?

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    public func fetchMenu() async throws -> [MenuItem] {
         return try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "menu")
            .method(.get)
            .decode(to: [MenuItem].self)
            .perform()
    }

    public func create(item: MenuItem) async throws {
        try await SwiftlyHttp(baseURL: baseURL)!
            .add(path: "menu")
            .method(.post)
            .authorizationDelegate(authDelegate!)
            .body(item)
            .decode(to: MenuItem.self)
            .perform()
    }
}

final class MenuRepositoryMck: MenuRepository {

    var authDelegate: AuthorizationDelegate?

    func fetchMenu() async throws -> [MenuItem] {
        [.init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", price: 100),
         .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", price: 100),
         .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", price: 100)
        ]
    }

    func create(item: GenericsModels.MenuItem) async throws {
    }
}
