import Fluent
import Vapor
import SharedModels

final class OrderAddressEntry: Model {
    static var schema = "order_addresses"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "latitude")
    var latitude: Double

    @Field(key: "longitude")
    var longitude: Double

    @Field(key: "street")
    var street: String

    @Field(key: "floor")
    var floor: Int?

    @Field(key: "appartment")
    var appartment: String?

    @Field(key: "comment")
    var comment: String?

    @Parent(key: "order_id")
    var order: OrderEntry

    init() { }

    init(
        id: UUID? = nil,
        latitude: Double,
        longitude: Double,
        street: String,
        floor: Int? = nil,
        appartment: String? = nil,
        comment: String? = nil,
        orderId: UUID
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.street = street
        self.floor = floor
        self.appartment = appartment
        self.comment = comment
        self.$order.id = orderId
    }
}
