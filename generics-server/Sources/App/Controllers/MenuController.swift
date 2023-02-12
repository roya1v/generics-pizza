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
    }

    func index(req: Request) async throws -> [MenuEntryJson] {
        let mockedEntries: [MenuEntryJson] = [
            .init(id: UUID(), title: "Margarita simplita", description: "Tomatoe souce, cheese and weird leaves", imageUrl: ""),
            .init(id: UUID(), title: "Pepperoni Meroni", description: "Tomatoe souce, cheese and weird leaves", imageUrl: ""),
            .init(id: UUID(), title: "Super pepperoni", description: "Tomatoe souce, cheese and weird leaves", imageUrl: "")
        ]
        return mockedEntries
    }
}

