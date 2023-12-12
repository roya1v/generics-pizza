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
    @Published var title = ""
    @Published var description = ""
    @Published var price = 0.0
    @Published var imageUrl: URL? = nil

    @Injected(\.menuRepository)
    private var menuRepository

    @Injected(\.authenticationRepository)
    private var authRepository

    func createMenuItem() {
        state = .loading

        guard !title.isEmpty,
              !description.isEmpty,
              price != 0.0 else {
            state = .error
            return
        }

        menuRepository.authFactory = { try? self.authRepository.getAuthentication() }
        let item = MenuItem(id: nil, title: title, description: description, price: Int(price * 100))
        Task {
            do {
                let menuItem = try await menuRepository.create(item: item)
                try await menuRepository.setImage(from: imageUrl!, for: menuItem)
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
