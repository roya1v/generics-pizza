//
//  MenuItem.swift
//  
//
//  Created by Mike Shevelinsky on 12/03/2023.
//

import Foundation

public struct MenuItem: Codable, Identifiable {

    public init(id: UUID?, title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }

    //let imageUrl: URL?
    public let id: UUID?
    public let title: String
    public let description: String
}
