import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: MenuController())
    try app.register(collection: AuthenticationController())
}
