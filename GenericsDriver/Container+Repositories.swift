import Factory
import Foundation
import GenericsCore
import AuthLogic

extension Container {
    var driverRepository: Factory<DriverRepository> {
        self {
            buildDriverRepository(
                url: self.serverUrl(),
                authenticationProvider: self.authenticationRepository())
        }
        .singleton
    }
}
