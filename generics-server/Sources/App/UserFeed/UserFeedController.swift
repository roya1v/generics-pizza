//
//  UserFeedController.swift
//  
//
//  Created by Mike S. on 23/07/2023.
//

import Vapor
import GenericsModels

struct UserFeedController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let feed = routes.grouped("feed")
        feed.get(use: get)
        feed.post(use: update)

    }

    /// Get feed
    func get(req: Request) async throws -> [FeedCardType] {
        return []
    }

    /// Update feed
    func update(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)
        let cards = try req.content.decode([FeedCardType].self)

        let transformedCards = cards.map { card in
            switch card {
            case let .bigImage(title, subtitle, imageSource, cta):
                let image: String
                switch imageSource {
                case let .remote(url):
                    image = url.absoluteString
                case let .local(name):
                    image = name
                }
                return FeedCardEntry(title: title, subtitle: subtitle, cta: cta?.rawValue, image: image)
            case .carousel:
                return FeedCardEntry(title: "title")
            case let .cta(title, subtitle, cta):
                return FeedCardEntry(title: title, subtitle: subtitle, cta: cta.rawValue)
            }

        }

        return .accepted
    }
}

extension FeedCardType: Content { }
