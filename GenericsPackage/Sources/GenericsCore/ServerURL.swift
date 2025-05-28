import Foundation
import Factory

extension Container {
    public var serverURL: Factory<URL> {
        self { URL(string: "http://localhost:8080")! }
    }
}
