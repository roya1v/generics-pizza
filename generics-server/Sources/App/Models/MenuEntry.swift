//
//  MenuEntry.swift
//  
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import Fluent
import Vapor

struct MenuEntryJson: Content {
    let id: UUID
    let title: String
    let description: String
    let imageUrl: String
}
