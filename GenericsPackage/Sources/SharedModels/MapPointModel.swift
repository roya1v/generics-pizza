import Foundation

public struct MapPointModel: Codable, Equatable {

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public let latitude: Double
    public let longitude: Double
}
