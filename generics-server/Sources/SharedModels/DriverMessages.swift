//
//  DriverMessages.swift
//  
//
//  Created by Mike S. on 16/08/2023.
//

import Foundation

public enum DriverMessage {
    case locationUpdated(lon: Double, lat: Double)

    enum CodingKeys: String, CodingKey {
        case message = "message"
        case lon
        case lat
    }
}

extension DriverMessage: Codable {
    public func encode(to encoder: Encoder) throws {
        var test = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .locationUpdated(let lon, let lat):
            try test.encode("location-update", forKey: .message)
            try test.encode(lon, forKey: .lon)
            try test.encode(lat, forKey: .lat)
        }
    }

    public init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: CodingKeys.self)
        let type = try rootContainer.decode(String.self, forKey: .message)

        switch type {
        case "location-update":
            self = .locationUpdated(lon: try rootContainer.decode(Double.self, forKey: .lon),
                                    lat: try rootContainer.decode(Double.self, forKey: .lat))
        default:
            fatalError()
        }
    }
}
