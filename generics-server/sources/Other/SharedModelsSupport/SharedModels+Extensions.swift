import Vapor
import SharedModels

extension MenuItem: Content { }

extension OrderModel: Content { }

extension MapPointModel: Content { }

extension AddressModel: Content { }

extension SubtotalModel: Content { }

extension UserModel: Content { }

extension MenuItem: EntryRepresentable {
    func toEntry() -> MenuEntry {
        MenuEntry(id: id, title: title, description: description, price: price)
    }
}

extension AddressModel: EntryRepresentable {
    func toEntry() -> AddressEntry {
        AddressEntry(details: details, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}
