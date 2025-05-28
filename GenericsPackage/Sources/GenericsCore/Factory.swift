import Foundation
import Factory

extension Container {

    public var serverUrl: Factory<String> {
        self { "http://localhost:8080" }
    }
}
