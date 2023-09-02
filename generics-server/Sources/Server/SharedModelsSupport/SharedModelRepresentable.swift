//
//  SharedModelRepresentable.swift
//  
//
//  Created by Mike S. on 02/09/2023.
//

import Foundation

protocol SharedModelRepresentable {
    associatedtype SharedModel: Codable

    func toSharedModel() -> SharedModel
}

extension Collection where Element: SharedModelRepresentable {
    func toSharedModels() -> [Element.SharedModel] {
        map { $0.toSharedModel() }
    }
}
