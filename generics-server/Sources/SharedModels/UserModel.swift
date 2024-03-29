//
//  User.swift
//
//
//  Created by Mike S. on 20/11/2023.
//

import Foundation

public struct UserModel: Codable, Equatable, Identifiable {
    public init(id: UUID? = nil, email: String) {
        self.id = id
        self.email = email
    }
    
    public let id: UUID?
    public let email: String
}

public enum UserAccess: String, Codable {
    case client
    case employee
    case admin
}
