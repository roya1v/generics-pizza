//
//  MenuViewModel.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation
import Factory

final class MenuViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var repository

    @Published var items = [MenuItem]()
    @Published var isLoading = false

    func fetch() {
        isLoading = true
        Task {
            items = try! await repository.fetchMenu()
            isLoading = false
        }
    }
}
