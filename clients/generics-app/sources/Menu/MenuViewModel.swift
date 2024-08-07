//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 02/02/2023.
//

import Foundation
import Factory
import SharedModels
import clients_libraries_GenericsUI
import clients_libraries_GenericsHelpers

@MainActor
final class MenuViewModel: ObservableObject {

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var state: ViewState = .ready

    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.orderRepository)
    private var orderRepository

    func fetch() {
        if items.isEmpty {
            state = .loading
        }
        ThrowingAsyncTask {
            try await self.menuRepository.fetchMenu()
        } onResult: { newItems in
            self.items = newItems
            self.state = .ready
        } onError: { _ in
            self.state = .error
        }
    }

    func imageUrl(for item: MenuItem) -> URL? {
        menuRepository.imageUrl(for: item)
    }
}
