//
//  Request+requireUser.swift
//
//
//  Created by Mike S. on 19/11/2023.
//

import Vapor

extension Request {

    @discardableResult
    func requireAnyUser() throws -> UserEntry {
        try auth.require(UserEntry.self)
    }

    @discardableResult
    func requireEmployeeOrAdminUser() throws -> UserEntry {
        let user = try requireAnyUser()
        guard user.access == .employee || user.access == .admin else {
            throw Abort(.unauthorized)
        }
        return user
    }

    @discardableResult
    func requireAdminUser() throws -> UserEntry {
        let user = try requireAnyUser()
        guard user.access == .admin else {
            throw Abort(.unauthorized)
        }
        return user
    }
}
