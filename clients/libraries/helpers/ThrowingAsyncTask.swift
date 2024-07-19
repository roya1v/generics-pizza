//
//  ThrowingAsyncTask.swift
//  GenericsHelpers
//
//  Created by Mike S. on 23/09/2023.
//

import Foundation

// swiftlint:disable:next identifier_name
public func ThrowingAsyncTask<T>(_ task: @escaping () async throws -> T,
                                 onResult: @escaping (T) -> Void,
                                 onError: ((Error) -> Void)?) {
    Task {
        do {
            let result = try await task()
            await MainActor.run {
                onResult(result)
            }
        } catch {
            await MainActor.run {
                onError?(error)
            }
        }
    }
}
