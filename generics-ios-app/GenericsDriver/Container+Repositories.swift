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
    var authenticationRepository: Factory<AuthenticationRepository> {
        self { buildAuthenticationRepository(url: url) }
        .singleton
    }

    var mainRouter: Factory<AppRouter> {
        self { AppRouter() }
        .singleton
    }

    var locationRepository: Factory<LocationRepository> {
        self { LocationRepository() }
        .singleton
    }

    var driverRepository: Factory<DriverRepository> {
        self { buildDriverRepository(url: url, authenticationRepository: self.authenticationRepository()) }
        .singleton
    }

    var routingService: Factory<RoutingService> {
        self { buildRoutingService() }
    }

    var mainStateHolder: Factory<MainStateHolder> {
        self { MainStateHolder() }
    }
}
