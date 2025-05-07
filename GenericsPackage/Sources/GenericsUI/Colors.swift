import SwiftUI

public extension Color {
    static let gAccent = Color.black
    static let gInactive = Color.gray

#if canImport(UIKit)
    static let gLight = Color(uiColor: .systemGray6)
#endif
}
