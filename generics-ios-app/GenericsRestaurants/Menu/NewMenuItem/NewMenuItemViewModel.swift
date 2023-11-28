//
//  NewMenuItemViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/03/2023.
//

import Foundation
import SharedModels
import Factory
import AppKit
import GenericsUI

@MainActor
final class NewMenuItemViewModel: ObservableObject {

    @Published private(set) var state: ViewState = .ready

    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.authenticationRepository)
    private var authRepository

    func createMenuItem(title: String, description: String, price: String) {
        state = .loading

        menuRepository.authFactory = { try? self.authRepository.getAuthentication() }
        let item = MenuItem(id: nil, title: title, description: description, price: Int(price)!)
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
