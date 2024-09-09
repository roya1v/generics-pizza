import Foundation

protocol LocalSettingsService {
    func getAuthToken() -> String?
    func setAuthToken(_ newToken: String)
    func resetAuthToken()
}

final class LocalSettingsServiceImpl: LocalSettingsService {

    private let authTokenKey = "auth-token"

    func getAuthToken() -> String? {
        UserDefaults.standard.string(forKey: authTokenKey)
    }

    func setAuthToken(_ newToken: String) {
        UserDefaults.standard.set(newToken, forKey: authTokenKey)
    }

    func resetAuthToken() {
        UserDefaults.standard.set(nil, forKey: authTokenKey)
    }
}
