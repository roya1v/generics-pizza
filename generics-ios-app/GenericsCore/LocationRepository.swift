//
//  LocationRepository.swift
//  GenericsDriver
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation
import CoreLocation
import Combine
import SharedModels

public protocol LocationService {
    
}

public final class LocationRepository: NSObject {

    public enum LocationState {
        case unknown
        case needLocationWhenInUse
        case needLocationAlways
        case needPrecision
        case ready
    }

    public var statePublisher: AnyPublisher<LocationState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    public var state: LocationState = .unknown {
        didSet {
            stateSubject.send(state)
        }
    }

    private let stateSubject = PassthroughSubject<LocationState, Never>()

    private let locationManager = CLLocationManager()

    override public init() {
        super.init()
        checkState()
        locationManager.delegate = self
    }

    private func checkState() {
        switch locationManager.authorizationStatus {
        case .restricted:
            state = .unknown
        case .notDetermined:
            state = .needLocationWhenInUse
        case .denied:
            state = .needLocationAlways
        case .authorizedAlways:
            switch locationManager.accuracyAuthorization {
            case .fullAccuracy:
                state = .ready
            case .reducedAccuracy:
                state = .needLocationAlways
            @unknown default:
                fatalError()
            }
        case .authorizedWhenInUse:
            state = .needLocationAlways
        @unknown default:
            fatalError()
        }
    }

    public func requestPermission() {
        locationManager.requestAlwaysAuthorization()
    }

    public func startStuff() {
        locationManager.startUpdatingLocation()
    }
}

extension LocationRepository: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkState()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
    }
}
