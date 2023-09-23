//
//  RoutingService.swift
//  GenericsDriver
//
//  Created by Mike S. on 20/09/2023.
//

import Foundation
import MapKit

public func buildRoutingService() -> RoutingService {
    RoutingServiceImpl()
}

public protocol RoutingService {
    func getRoute(from start: CLLocationCoordinate2D,
                  to destination: CLLocationCoordinate2D) async throws -> MKPolyline
}

final class RoutingServiceImpl: RoutingService {


    func getRoute(from start: CLLocationCoordinate2D,
                  to destination: CLLocationCoordinate2D) async throws -> MKPolyline  {
        let request = MKDirections.Request()
        request.source = .init(placemark: .init(coordinate: start))
        request.destination = .init(placemark: .init(coordinate: destination))

        let directions = MKDirections(request: request)
        let stuff = try await directions.calculate()
        guard let route = stuff.routes.first else {
            fatalError()
        }
        return route.polyline
    }
}
