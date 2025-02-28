import Foundation

public struct DriverDetails: Codable, Equatable {

    public init(name: String, surname: String) {
        self.name = name
        self.surname = surname
    }
    
    public let name: String
    public let surname: String
}
