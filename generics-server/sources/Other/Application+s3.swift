import Vapor
import SotoS3

// swiftlint:disable nesting
extension Application {
    struct S3Key: StorageKey {
        typealias Value = S3
    }

    public var s3: S3 {
        get {
            guard let s3 = self.storage[S3Key.self] else {
                fatalError("S3 not setup. Use application.s3 = ...")
            }
            return s3
        }
        set {
            self.storage.set(S3Key.self, to: newValue) {
                try $0.client.syncShutdown()
            }
        }
    }
}

public extension Request {
    var s3: S3 {
        return application.s3
    }
}
// swiftlint:enable nesting
