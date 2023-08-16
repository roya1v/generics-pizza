//
//  Container+Repositories.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import Factory
import GenericsCore

fileprivate let url = "http://localhost:8080"

extension Container {
    static let authenticationRepository = Factory(scope: .singleton) { buildAuthenticationRepository(url: url) }
    static let mainRouter = Factory(scope: .singleton) { MainRouter() }
}
