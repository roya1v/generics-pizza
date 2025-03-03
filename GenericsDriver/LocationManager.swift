//
//  LocationManager.swift
//  GenericsPizza
//
//  Created by Mike S. on 03/03/2025.
//

import Foundation
import CoreLocation
import Combine
import Factory

extension Container {
    var locationManager: Factory<LocationManager> {
        self { LocationManagerImpl() }
            .singleton
    }
}

protocol LocationManager {
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
    func requestWhenInUseAuthorization()
}

final class LocationManagerImpl: NSObject,  LocationManager {
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationStatusPassthroughSubject.eraseToAnyPublisher()
    }

    private let authorizationStatusPassthroughSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let manager = CLLocationManager()

    override init() {
        super.init()

        self.manager.delegate = self
    }

    func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
}

extension LocationManagerImpl: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatusPassthroughSubject.send(manager.authorizationStatus)
    }
}
