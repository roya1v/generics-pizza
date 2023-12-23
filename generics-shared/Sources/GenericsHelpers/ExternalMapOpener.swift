//
//  ExternalMapOpener.swift
//  GenericsDriver
//
//  Created by Mike S. on 30/08/2023.
//

#if os(iOS)
import UIKit
import CoreLocation

enum MapsApp {
    case googleMaps // https://developers.google.com/maps/documentation/urls/ios-urlscheme
    case appleMaps // https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html#//apple_ref/doc/uid/TP40007899-CH5-SW1
    case waze // https://developers.google.com/waze/deeplinks

    var isInstalled: Bool {
        switch self {
        case .googleMaps:
            break
        case .appleMaps:
            break
        case .waze:
            break
        }
        return false
    }

    func open(at coordinates: CLLocationCoordinate2D) {
        switch self {
        case .googleMaps:
            openUrl("comgooglemaps://?center=\(coordinates.latitude),\(coordinates.longitude)&zoom=14&views=traffic")
        case .appleMaps:
            openUrl("http://maps.apple.com/?ll=\(coordinates.latitude),\(coordinates.longitude)")
        case .waze:
            break
        }
    }

    func open(routeFrom startCoordinate: CLLocationCoordinate2D,
              to finishCoordinate: CLLocationCoordinate2D) {
        switch self {
        case .googleMaps:
            break
        case .appleMaps:
            break
        case .waze:
            break
        }
    }

    private func openUrl(_ urlString: String) {
        let url = URL(string: urlString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension MapsApp: CaseIterable { }
#endif
