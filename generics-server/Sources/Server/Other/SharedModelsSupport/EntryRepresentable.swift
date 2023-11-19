//
//  EntryRepresentable.swift
//  
//
//  Created by Mike S. on 02/09/2023.
//

import Fluent

protocol EntryRepresentable {
    associatedtype Entry: Model

    func toEntry() -> Entry
}
