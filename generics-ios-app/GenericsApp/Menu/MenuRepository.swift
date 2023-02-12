//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation

import Factory

extension Container {
    static let menuRepository = Factory<MenuRepository> { MenuRepositoryImp() }
}

protocol MenuRepository {
    func fetchMenu() async throws -> [MenuItem]
}

struct MenuItem: Codable, Identifiable {
    //let imageUrl: URL?
    let id: UUID
    let title: String
    let description: String
}

class MenuRepositoryImp: MenuRepository {

    private let baseURL = "http://localhost:8080"

    func fetchMenu() async throws -> [MenuItem] {
        let url = baseURL + "/menu"
        let test = try await URLSession.shared.data(from: URL(string: url)!)

        return try JSONDecoder().decode([MenuItem].self, from: test.0)
    }
}

class MenuRepositoryMck: MenuRepository {
    func fetchMenu() async throws -> [MenuItem] {
        [.init(id: .init(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves"),
         .init(id: .init(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves"),
         .init(id: .init(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves")
        ]
    }
}
