import Vapor

struct SlowdownMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        try await Task.sleep(for: .seconds(3))
        return try await next.respond(to: request)
    }
}

struct ErrorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        throw Abort(.imATeapot, reason: "The server is running in error throwin mode for testing")
    }
}
