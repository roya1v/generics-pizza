//
//  AuthenticationProvider.swift
//
//
//  Created by Mike S. on 20/03/2024.
//

import Foundation
import clients_libraries_SwiftlyHttp

public protocol AuthenticationProvider {
    func getAuthentication() throws -> SwiftlyHttp.Authentication
}
