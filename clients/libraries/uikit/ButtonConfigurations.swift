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
