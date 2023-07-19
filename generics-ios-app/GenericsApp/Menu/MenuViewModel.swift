//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 02/02/2023.
//

import Foundation
import Factory
import GenericsModels
import GenericsUI

@MainActor
final class MenuViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var repository

    @Published private(set) var items = [MenuItem]()
    @Published private(set) var state: ViewState = .ready

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
