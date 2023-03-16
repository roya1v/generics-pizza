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

@MainActor
final class NewMenuItemViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var menuRepository
    @Injected(Container.authenticationRepository) private var authRepository

    @Published var isLoading = false
    @Published var occurredError: Error?

    func createMenuItem(title: String, description: String, price: String) {
        isLoading = true

        menuRepository.authDelegate = authRepository
        let item = MenuItem(id: nil, title: title, description: description)
        Task {
            do {
                try await menuRepository.create(item: item)
            } catch {
                await MainActor.run {
                    occurredError = error
                }
            }
            await MainActor.run {
                isLoading = false
                // TODO: Find a better way
                NSApplication.shared.keyWindow?.close()
            }
        }
    }
}
