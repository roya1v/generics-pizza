//
//  SharedModels+Extensions.swift
//  
//
//  Created by Mike S. on 02/09/2023.
//

import Vapor
import SharedModels

extension MenuItem: Content { }

extension OrderModel: Content { }

extension MapPointModel: Content { }

extension AddressModel: Content { }

extension MenuItem: EntryRepresentable {
    func toEntry() -> MenuEntry {
        .init(id: id, title: title, description: description, price: price, imageUrl: nil)
    }
}
