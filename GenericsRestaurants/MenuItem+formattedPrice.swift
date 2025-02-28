import Foundation
import SharedModels

extension MenuItem {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(price) / 100)
    }
}

extension SubtotalModel {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(value) / 100)
    }
}
