//
//  FeedCard.swift
//  
//
//  Created by Mike S. on 23/07/2023.
//

import Foundation

public enum FeedCardType: Codable, Equatable, Hashable {
    case carousel(title: String)

    case bigImage(title: String,
                  subtitle: String,
                  image: ImageSource,
                  ctaDestination: CtaDestination?)
    case cta(title: String,
             subtitle: String,
             ctaDestination: CtaDestination)

    enum CodingKeys: String, CodingKey {
        case type, title, subtitle, ctaDestination, image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "carousel":
            let title = try container.decode(String.self, forKey: .title)
            self = .carousel(title: title)
        case "bigImage":
            let title = try container.decode(String.self, forKey: .title)
            let subtitle = try container.decode(String.self, forKey: .subtitle)
            let ctaDestination = try container.decodeIfPresent(CtaDestination.self, forKey: .ctaDestination)
            let imageSource = try container.decode(ImageSource.self, forKey: .image)
            self = .bigImage(title: title, subtitle: subtitle, image: imageSource, ctaDestination: ctaDestination)
        case "cta":
            let title = try container.decode(String.self, forKey: .title)
            let subtitle = try container.decode(String.self, forKey: .subtitle)
            let ctaDestination = try container.decode(CtaDestination.self, forKey: .ctaDestination)
            self = .cta(title: title, subtitle: subtitle, ctaDestination: ctaDestination)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Invalid card type"
                )
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .carousel(let title):
            try container.encode("carousel", forKey: .type)
            try container.encode(title, forKey: .title)
        case .bigImage(let title, let subtitle, let imageSource, let ctaDestination):
            try container.encode("bigImage", forKey: .type)
            try container.encode(title, forKey: .title)
            try container.encode(subtitle, forKey: .subtitle)
            try container.encode(imageSource, forKey: .image)
            try container.encodeIfPresent(ctaDestination, forKey: .ctaDestination)
        case .cta(let title, let subtitle, let ctaDestination):
            try container.encode("cta", forKey: .type)
            try container.encode(title, forKey: .title)
            try container.encode(subtitle, forKey: .subtitle)
            try container.encode(ctaDestination, forKey: .ctaDestination)
        }
    }
}

public enum CtaDestination: String, Codable {
    case menu

    public var label: String {
        switch self {
        case .menu:
            return "Menu"
        }
    }
}

public enum ImageSource: Codable, Equatable, Hashable {
    case local(name: String)
    case remote(url: URL)
}
