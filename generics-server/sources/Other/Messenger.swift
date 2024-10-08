import Vapor

final class Messenger<IncomingMessage, OutgoingMessage>
    where IncomingMessage: Decodable, OutgoingMessage: Encodable {

    private let ws: WebSocket

    private var onMessage: ((IncomingMessage) -> Void)?

    init(ws: WebSocket, eventLoop: EventLoop) {
        self.ws = ws
        self.onMessage = nil
        eventLoop.execute {
            ws.onText { _, text in
                let message = try? JSONDecoder().decode(IncomingMessage.self, from: text)
                if let message {
                    self.onMessage?(message)
                }
            }
        }
    }

    func onMessage(_ callback: @escaping ((IncomingMessage) -> Void)) {
        onMessage = callback
    }

    func send(message: OutgoingMessage) async throws {
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        try await ws.send(string)
    }

    func send(message: OutgoingMessage) throws {
        let data = try JSONEncoder().encode(message)
        let string = String(decoding: data, as: UTF8.self)
        ws.send(string)
    }
}

extension JSONDecoder {
    public func decode<T: Decodable>(_ type: T.Type, from aString: String) throws -> T {
        guard let data = aString.data(using: .utf8) else {
            fatalError()
        }
        return try decode(type, from: data)
    }
}
