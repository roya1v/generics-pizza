import Foundation

public struct MenuItem: Codable, Identifiable, Equatable {

    public init(id: UUID?, title: String, description: String, price: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
    }

    public let id: UUID?
    public let title: String
    public let description: String
    public let price: Int
}
