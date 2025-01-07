import Vapor
import SharedModels

extension OrderModel: @retroactive Content { }

extension MapPointModel: @retroactive Content { }

extension OrderAddressEntry: @retroactive Content { }

extension SubtotalModel: @retroactive Content { }

extension UserModel: @retroactive Content { }

extension MenuItem: EntryRepresentable, @retroactive Content {
    func toEntry() -> MenuEntry {
        MenuEntry(id: id, title: title, description: description, price: price, categoryId: category?.id)
    }
}

extension MenuItem.Category: EntryRepresentable, @retroactive Content {
    func toEntry() -> CategoryEntry {
        CategoryEntry(id: id, name: name)
    }
}

extension DriverDetails: @retroactive Content { }
