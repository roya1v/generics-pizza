//
//  User.swift
//
//
//  Created by Mike S. on 20/11/2023.
//

import Foundation

public struct UserModel: Codable, Equatable, Identifiable {
    public enum AccessLevel: String, Codable {
        case client
        case employee
        case admin
    }

    public init(id: UUID? = nil, email: String, access: AccessLevel) {
        self.id = id
        self.email = email
        self.access = access
    }

    public let id: UUID?
    public let email: String
    public let access: AccessLevel
}
