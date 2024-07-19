//
//  MenuDetailViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 19/07/2024.
//

import Foundation
import Factory
import SharedModels
import clients_libraries_GenericsUI
import clients_libraries_GenericsHelpers

@MainActor
final class MenuDetailViewModel: ObservableObject {
    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.orderRepository)
    private var orderRepository

    let item: MenuItem

    init(item: MenuItem) {
        self.item = item
    }

    func add() {
        orderRepository.add(item: item)
    }

    func imageUrl() -> URL? {
        menuRepository.imageUrl(for: item)
    }
}
