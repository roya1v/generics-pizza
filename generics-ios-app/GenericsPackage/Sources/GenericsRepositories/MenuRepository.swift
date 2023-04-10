//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation
import GenericsModels
import GenericsHttp

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
        let response = try await GenericsHttp(baseURL: baseURL)!
            .add(path: "menu")
            .method(.get)
            .perform()

        return try JSONDecoder().decode([MenuItem].self, from: response.0)
    }

    public func create(item: MenuItem) async throws {
        let response = try await GenericsHttp(baseURL: baseURL)!
            .add(path: "menu")
            .method(.post)
            .authorizationDelegate(authDelegate!)
            .body(item)
            .perform()

        _ = try JSONDecoder().decode(MenuItem.self, from: response.0)
    }
}

final class MenuRepositoryMck: MenuRepository {

    var authDelegate: AuthorizationDelegate?

    func fetchMenu() async throws -> [MenuItem] {
        [.init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves"),
         .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves"),
         .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves")
        ]
    }

    func create(item: GenericsModels.MenuItem) async throws {
    }
}
