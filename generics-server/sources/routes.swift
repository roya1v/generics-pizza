import Fluent
import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: MenuController())
    try app.register(collection: AuthenticationController())
    try app.register(collection: OrdersController())
    try app.register(collection: UserController())
}
