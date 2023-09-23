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

@MainActor
final class MenuViewModel: ObservableObject {

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var state: ViewState = .ready

    @Injected(\.menuRepository)
    private var repository

    func fetch() {
        if items.isEmpty {
            state = .loading
        }
        Task {
            do {
                let newItems = try await repository.fetchMenu()
                await MainActor.run {
                    state = .ready
                    items = newItems
                }
            } catch {
                state = .error
            }
        }
    }
}
