//
//  User+ModelTokenAuthenticatable.swift
//  
//
//  Created by Mike Shevelinsky on 13/02/2023.
//

import Vapor
import Fluent

extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
