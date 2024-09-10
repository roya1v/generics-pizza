import Foundation

public struct MenuItem: Codable, Identifiable, Equatable {

    public init(id: UUID?,
                title: String,
                description: String,
                price: Int, isHidden: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.isHidden = isHidden
    }

    public let id: UUID?
    public let title: String
    public let description: String
    public let price: Int
    public let isHidden: Bool
}
