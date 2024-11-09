import Foundation

public struct OrderModel: Codable, Identifiable, Equatable {
    public init(id: UUID? = nil,
                createdAt: Date? = nil,
                items: [Item],
                state: State? = nil,
                destination: Destination) {
        self.id = id
        self.createdAt = createdAt
        self.items = items
        self.state = state
        self.destination = destination
    }

    public let id: UUID?
    public let createdAt: Date?
    public let items: [Item]
    public let state: State?
    public let destination: Destination

    public struct Item: Codable, Equatable {
        public init(menuItem: MenuItem, count: Int) {
            self.menuItem = menuItem
            self.count = count
        }

        public let menuItem: MenuItem
        public let count: Int
    }

    public enum State: String, Codable {
        case new
        case inProgress
        case readyForDelivery
        case inDelivery
        case finished
    }

    public enum Destination: Codable, Equatable {
        case delivery(Address)
        case pickUp

        public struct Address: Codable, Equatable {
            public init(
                street: String,
                floor: Int?,
                appartment: String? = nil,
                comment: String,
                coordinates: MapPointModel
            ) {
                self.street = street
                self.floor = floor
                self.appartment = appartment
                self.comment = comment
                self.coordinates = coordinates
            }

            public let street: String
            public let floor: Int?
            public let appartment: String?
            public let comment: String
            public let coordinates: MapPointModel
        }
    }
}
