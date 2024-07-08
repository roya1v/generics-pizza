//
//  MenuItem+formattedPrice.swift
//  GenericsApp
//
//  Created by Mike S. on 17/06/2023.
//

import Foundation
import SharedModels

extension MenuItem {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(price) / 100)
    }
}

extension SubtotalModel {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(value) / 100)
    }
}
