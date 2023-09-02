//
//  MapPointModel+CLLocationCoordinate2D.swift
//  GenericsApp
//
//  Created by Mike S. on 02/09/2023.
//

import Foundation
import CoreLocation
import SharedModels

extension MapPointModel {
    var clLocationCoordinate2d: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CLLocationCoordinate2D {
    var mapPointModel: MapPointModel {
        MapPointModel(latitude: latitude, longitude: longitude)
    }
}
