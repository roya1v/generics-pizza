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
        case notNeeded
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
    var body: Data?
    var headers = [String: String]()
    weak var authDelegate: AuthorizationDelegate?

    public init?(baseURL: String) {
        if let url = URL(string: baseURL) {
            self.baseURL = url
        } else {
            return nil
        }
    }

    public func add(path: String) -> Self {
        if #available(iOS 16.0, *) {
            baseURL = baseURL.appending(path: path)
        } else {
            baseURL = baseURL.appendingPathComponent(path)
        }
        return self
    }

    public func authorization(_ auth: Authorization) -> Self {
        self.auth = auth
        return self
    }

    public func authorizationDelegate(_ delegate: AuthorizationDelegate) -> Self {
        authDelegate = delegate
        return self
    }

    public func method(_ method: Method) -> Self {
        self.method = method
        return self
    }

    public func body(_ body: some Encodable) throws -> Self {
        self.body = try JSONEncoder().encode(body)
        headers["Content-Type"] = "application/json"
        return self
    }

    public func perform() async throws -> (Data, URLResponse) {
        let url = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        var request = URLRequest(url: url.url!)

        if let delegate = authDelegate {
            let auth = try delegate.getAuthorization()
            addAuthorizationIfNeeded(to: &request, auth: auth)
        } else if let auth = auth {
            addAuthorizationIfNeeded(to: &request, auth: auth)
        }

        request.httpMethod = method.stringValue
        request.httpBody = body
        headers.forEach { pair in
            request.setValue(pair.value, forHTTPHeaderField: pair.key)
        }

        return try await URLSession.shared.data(for: request)
    }

    private func addAuthorizationIfNeeded(to request: inout URLRequest, auth: Authorization) {
        switch auth {
        case .basic(let login, let password):
            let token = String(format: "%@:%@", login, password).data(using: .utf8)!.base64EncodedData()
            request.setValue("Basic \(String(data: token, encoding: .utf8)!)", forHTTPHeaderField: "Authorization")
        case .bearer(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        case .notNeeded:
            return
        }
    }
}

public protocol AuthorizationDelegate: AnyObject {
    func getAuthorization() throws -> GenericsHttp.Authorization
}
