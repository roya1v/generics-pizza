//
//  SubtotalModel.swift
//  
//
//  Created by Mike S. on 20/06/2023.
//

import Foundation

public struct SubtotalModel: Codable {
    public init(name: String, value: Int, isSecondary: Bool = true) {
        self.name = name
        self.value = value
        self.isSecondary = isSecondary
    }

    public let name: String
    public let value: Int
    public let isSecondary: Bool
}
