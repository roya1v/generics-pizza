import Foundation
import Factory
import clients_libraries_GenericsCore

extension Container {
    var menuRepository: Factory<MenuRepository> {
        self { buildMenuRepository(
            url: self.serverUrl(),
            authenticationProvider: nil)
        }
    }
}
