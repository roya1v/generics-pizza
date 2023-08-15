//
//  Subtotal.swift
//  
//
//  Created by Mike Shevelinsky on 19/06/2023.
//

import Foundation
import Vapor

final class Subtotal: Content {
    let name: String
    let value: Int
    let isSecondary: Bool

    init(name: String, value: Int, isSecondary: Bool = true) {
        self.name = name
        self.value = value
        self.isSecondary = isSecondary
    }
}
