import Vapor
import SharedModels

extension OrderModel: @retroactive Content { }

extension MapPointModel: @retroactive Content { }

extension AddressModel: @retroactive Content { }

extension SubtotalModel: @retroactive Content { }

extension UserModel: @retroactive Content { }

extension MenuItem: EntryRepresentable, @retroactive Content {
    func toEntry() -> MenuEntry {
        MenuEntry(id: id, title: title, description: description, price: price, category: nil)
    }
}

extension AddressModel: EntryRepresentable {
    func toEntry() -> AddressEntry {
        AddressEntry(details: details, latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension MenuItem.Category: EntryRepresentable, @retroactive Content {
    func toEntry() -> CategoryEntry {
        CategoryEntry(id: id, name: name)
    }
}
