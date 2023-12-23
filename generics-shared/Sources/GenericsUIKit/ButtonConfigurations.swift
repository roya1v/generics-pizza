//
//  ButtonConfigurations.swift
//  GenericsUIKit
//
//  Created by Mike S. on 30/08/2023.
//

import UIKit

public extension UIButton.Configuration {
    static func primary() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderedProminent()
        configuration.baseBackgroundColor = .black
        return configuration
    }

    static func secondary() -> UIButton.Configuration {
        var configuration = UIButton.Configuration.borderedTinted()
        configuration.baseBackgroundColor = .black
        configuration.baseForegroundColor = .white
        return configuration
    }
}
