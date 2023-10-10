//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 02/02/2023.
//

import Foundation
import Factory
import SharedModels
import GenericsUI
import GenericsHelpers

final class MenuViewModel: ObservableObject {

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var state: ViewState = .ready

    @Injected(\.menuRepository)
    private var repository

    func fetch() {
        if items.isEmpty {
            state = .loading
        }
        ThrowingAsyncTask {
            return try await self.repository.fetchMenu()
        } onResult: { newItems in
            self.items = newItems
            self.state = .ready
        } onError: { error in
            self.state = .error
        }
    }
}
