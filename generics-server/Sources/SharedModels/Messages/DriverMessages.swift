//
//  DriverMessages.swift
//  
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation

enum DriverToServerMessage: Codable {
    case locationUpdated(lon: Double, lat: Double)
    case acceptOrder
}

enum DriverFromServerMessage: Codable {
    case offerOrder
}
