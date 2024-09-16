import Foundation
import SharedModels
import clients_libraries_SwiftlyHttp
import Spyable
import Factory

extension Container {
    public var menuRepository: Factory<MenuRepository> {
        self { MenuRepositoryImp(baseURL: self.serverUrl(), authenticationProvider: nil) }
    }
}

// Kept temporarily for restaurant app
public func buildMenuRepository(url: String, authenticationProvider: AuthenticationProvider? = nil) -> MenuRepository {
    MenuRepositoryImp(baseURL: url, authenticationProvider: authenticationProvider)
}

@Spyable
public protocol MenuRepository {
    func fetchMenu() async throws -> [MenuItem]
    func fetchMenu(showHidden: Bool) async throws -> [MenuItem]
    func create(item: MenuItem) async throws -> MenuItem
    func delete(item: MenuItem) async throws
    func update(item: MenuItem) async throws -> MenuItem
    func imageUrl(for item: MenuItem) -> URL?
    func getImage(forItemId id: UUID) async throws -> ImageData
    func setImage(from localUrl: URL, for item: MenuItem) async throws
}

enum MenuRepositoryError: Error {
    case invalidFile
    case httpError(Int)
}

final class MenuRepositoryImp: MenuRepository {

    private let baseURL: String
    private let authenticationProvider: AuthenticationProvider?

    init(baseURL: String, authenticationProvider: AuthenticationProvider?) {
        self.baseURL = baseURL
        self.authenticationProvider = authenticationProvider
    }

    // MARK: - MenuRepository

    public func fetchMenu() async throws -> [MenuItem] {
         try await fetchMenu(showHidden: false)
    }

    public func fetchMenu(showHidden: Bool) async throws -> [MenuItem] {
         return try await getRequest()
            .method(.get)
            .add(queryParameter: "showHidden", value: "\(showHidden)")
            .authentication({
                try? self.authenticationProvider?.getAuthentication()
            })
            .decode(to: [MenuItem].self)
            .perform()
    }

    public func create(item: MenuItem) async throws -> MenuItem {
        try await getRequest()
            .method(.post)
            .authentication({
                try? self.authenticationProvider?.getAuthentication()
            })
            .body(item)
            .decode(to: MenuItem.self)
            .perform()
    }

    func update(item: MenuItem) async throws -> MenuItem {
        try await getRequest()
            .method(.put)
            .authentication({
                try? self.authenticationProvider?.getAuthentication()
            })
            .body(item)
            .decode(to: MenuItem.self)
            .perform()
    }

    func imageUrl(for item: SharedModels.MenuItem) -> URL? {
        guard let idString = item.id?.uuidString else {
            return nil
        }
        return URL(string: "\(baseURL)/menu/\(idString)/image")
    }

    func getImage(forItemId id: UUID) async throws -> ImageData {
        let (data, response) = try await getRequest()
            .method(.get)
            .add(path: "\(id.uuidString)")
            .add(path: "image")
            .perform()
        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw MenuRepositoryError.httpError(500)
        }
        guard let image = ImageData(data: data) else {
            fatalError()
        }
        return image
    }

    private func getRequest() -> SwiftlyHttp {
        SwiftlyHttp(baseURL: baseURL)!
            .add(path: "menu")
    }

    func setImage(from localUrl: URL, for item: MenuItem) async throws {
        guard localUrl.isFileURL else {
            throw MenuRepositoryError.invalidFile
        }
        let imageData = try Data(contentsOf: localUrl)
        try await getRequest()
            .method(.post)
            .add(path: item.id!.uuidString)
            .add(path: "image")
            .authentication({
                try? self.authenticationProvider?.getAuthentication()
            })
            .setHeader("Content-Type", to: "image/jpeg")
            .body(imageData)
            .perform()
    }

    func delete(item: MenuItem) async throws {
        try await getRequest()
            .method(.delete)
            .add(path: item.id!.uuidString)
            .authentication({
                try? self.authenticationProvider?.getAuthentication()
            })
            .perform()
    }
}
