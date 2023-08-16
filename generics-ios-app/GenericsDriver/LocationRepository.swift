//
//  LocationRepository.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import CoreLocation
import Combine

final class LocationRepository: NSObject, CLLocationManagerDelegate {

    enum LocationState {
        case loading
        case needLocationWhenInUse
        case needLocationAlways
        case needPrecision
        case ready
    }

    var state: AnyPublisher<LocationState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var currentState: LocationState = .loading {
        didSet {
            stateSubject.send(currentState)
        }
    }

    private let stateSubject = PassthroughSubject<LocationState, Never>()

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        checkState()
        locationManager.delegate = self
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkState()
    }

    private func checkState() {
        switch locationManager.authorizationStatus {
        case .restricted:
            currentState = .loading
        case .notDetermined:
            currentState = .needLocationWhenInUse
        case .denied:
            currentState = .needLocationAlways
        case .authorizedAlways:
            switch locationManager.accuracyAuthorization {
            case .fullAccuracy:
                currentState = .ready
            case .reducedAccuracy:
                currentState = .needLocationAlways
            @unknown default:
                fatalError()
            }
        case .authorizedWhenInUse:
            currentState = .needLocationAlways
        @unknown default:
            fatalError()
        }
    }

    func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }
}
