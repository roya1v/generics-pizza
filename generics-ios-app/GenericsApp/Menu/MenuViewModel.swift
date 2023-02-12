//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation
import Factory

@MainActor
final class MenuViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var repository

    @Published private(set) var items = [MenuItem]()
    @Published private(set) var isLoading = false

    func fetch() {
        isLoading = true
        Task {
            let newItems = try! await repository.fetchMenu()
            try! await Task.sleep(for: .seconds(2))
            await MainActor.run {
                isLoading = false
                items = newItems
            }
        }
    }
}
