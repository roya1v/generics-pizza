import Fluent
import Vapor
import SharedModels
import PathKit

struct DriverController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        let driver = routes.grouped("driver").grouped(UserTokenEntry.authenticator())

        driver.get("details", use: details)
    }

    /// Get details about the driver
    func details(req: Request) -> DriverDetails {
        DriverDetails(name: "Jan", surname: "Kowalski")
    }
}
