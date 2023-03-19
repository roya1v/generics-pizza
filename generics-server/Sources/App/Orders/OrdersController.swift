//
//  OrdersController.swift
//  
//
//  Created by Mike S. on 16/03/2023.
//

import Fluent
import Vapor
import GenericsModels

class OrdersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let order = routes.grouped("order")
        let authenticated = order.grouped(UserToken.authenticator())
        authenticated.grouped("current").get(use: getCurrent)
        order.post(use: new)

        order.grouped("activity").grouped(":orderId").webSocket(onUpgrade: orderActivity)
        order.grouped("activity").grouped(UserToken.authenticator()).webSocket(onUpgrade: adminActivity)
    }

    func getCurrent(req: Request) async throws -> [Order] {
        throw Abort(.notImplemented)
    }

    func new(req: Request) async throws -> Order {
        throw Abort(.notImplemented)
    }

    var clients = [String: WebSocket]()

    func orderActivity(req: Request, ws: WebSocket) async {
        guard let id = req.parameters.get("orderId") else {
            try! await ws.close()
            return
        }
        clients[id] = ws
    }

    func adminActivity(req: Request, ws: WebSocket) async {
        ws.onText { ws, text in
            if let client = self.clients[text] {
                client.send("Something!")
            }
        }
    }
}
