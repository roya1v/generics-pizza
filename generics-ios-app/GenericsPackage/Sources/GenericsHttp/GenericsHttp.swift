//
//  GenericsHttp.swift
//  
//
//  Created by Mike Shevelinsky on 15/02/2023.
//

import Foundation

public class GenericsHttp {

    public enum Authorization {
        case basic(login: String, password: String)
        case bearer(token: String)
    }

    public enum Method {
        case post
        case get

        var stringValue: String {
            switch self {
            case .post:
                return "POST"
            case .get:
                return "GET"
            }
        }
    }

    var baseURL: URL
    var pathComponents = [String]()
    var auth: Authorization?
    var method: Method = .get

    public init?(baseURL: String) {
        if let url = URL(string: baseURL) {
            self.baseURL = url
        } else {
            return nil
        }
    }

    public func add(path: String) -> Self {
        baseURL = baseURL.appending(path: path)
        return self
    }

    public func authorization(_ auth: Authorization) -> Self {
        self.auth = auth
        return self
    }

    public func method(_ method: Method) -> Self {
        self.method = method
        return self
    }

    public func perform() async throws -> (Data, URLResponse) {
        let url = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: url.url!)

        addAuthenticationIfNeeded(to: &request)
        request.httpMethod = method.stringValue

        return try await URLSession.shared.data(for: request)
    }

    private func addAuthenticationIfNeeded(to request: inout URLRequest) {
        guard let auth = auth else {
            return
        }

        switch auth {
        case .basic(let login, let password):
            let token = String(format: "%@:%@", login, password).data(using: .utf8)!.base64EncodedData()
            request.setValue("Basic \(String(data: token, encoding: .utf8)!)", forHTTPHeaderField: "Authorization")
        case .bearer(_):
            fatalError("Bearer token not yet implemented")
        }
    }
}
