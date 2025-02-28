import Factory
import Foundation
import GenericsCore

extension Container {
    public var authenticationRepository: Factory<AuthenticationRepository> {
        self { buildAuthenticationRepository(url: self.serverUrl()) }
            .singleton
    }
}
