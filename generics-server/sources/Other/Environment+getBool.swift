import Vapor

extension Environment {
    static func get(_ key: String) -> Bool {
        get(key) == "TRUE"
    }
}
