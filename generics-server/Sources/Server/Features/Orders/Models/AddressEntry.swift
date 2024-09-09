import Fluent
import Vapor
import SharedModels

final class AddressEntry: Model {
    static var schema = "addresses"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "details")
    var details: String?

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    init() { }

    init(id: UUID? = nil, details: String?, latitude: Double, longitude: Double) {
        self.id = id
        self.details = details
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension AddressEntry: SharedModelRepresentable {
    func toSharedModel() -> AddressModel {
        .init(coordinate: .init(latitude: latitude, longitude: longitude), details: details ?? "")
    }
}
