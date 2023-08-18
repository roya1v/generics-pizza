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

final class LocationRepository: NSObject {

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

    func startStuff() {
        locationManager.startUpdatingLocation()
    }
}

extension LocationRepository: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkState()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let message = DriverMessage.locationUpdated(lon: location.coordinate.longitude, lat: location.coordinate.latitude)

        let data = try? JSONEncoder().encode(message)

        let string = String(data: data!, encoding: .utf8)!
        print(string)
    }
}
