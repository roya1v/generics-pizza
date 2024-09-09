import Foundation

public struct AddressModel: Codable {

    public init(coordinate: MapPointModel, details: String) {
        self.coordinate = coordinate
        self.details = details
    }

    public let coordinate: MapPointModel
    public let details: String
}

public struct MapPointModel: Codable {

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public let latitude: Double
    public let longitude: Double
}
