//
//  NewMenuItemViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/03/2023.
//

import Foundation
import GenericsModels
import Factory
import AppKit
import GenericsUI

@MainActor
final class NewMenuItemViewModel: ObservableObject {

    @Published private(set) var state: ViewState = .ready
    @Published var isLoading = false
    @Published var occurredError: Error?

    @Injected(Container.menuRepository)
    private var menuRepository

    @Injected(Container.authenticationRepository)
    private var authRepository

    func createMenuItem(title: String, description: String, price: String) {
        state = .loading

        menuRepository.authDelegate = authRepository
        let item = MenuItem(id: nil, title: title, description: description, price: 0)
        Task {
            do {
                try await menuRepository.create(item: item)
            } catch {
                await MainActor.run {
                    state = .error
                }
            }
            await MainActor.run {
                state = .ready
                // TODO: Find a better way
                NSApplication.shared.keyWindow?.close()
            }
        }
    }
}
