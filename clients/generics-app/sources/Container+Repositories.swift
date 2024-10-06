import Factory
import Foundation
import GenericsCore

extension Container {
    var menuRepository: Factory<MenuRepository> {
        self {
            buildMenuRepository(
                url: self.serverUrl(),
                authenticationProvider: nil)
        }
    }
}
