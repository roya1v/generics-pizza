//
//  DriverMessages.swift
//  
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation

public enum DriverToServerMessage: Codable {
    case locationUpdated(lon: Double, lat: Double)
    case acceptOrder
}

public enum DriverFromServerMessage: Codable {
    case offerOrder
}
