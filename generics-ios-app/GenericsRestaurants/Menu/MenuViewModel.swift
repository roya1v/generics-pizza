//
//  MenuViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 13/03/2023.
//

import Foundation
import GenericsModels

final class MenuViewModel: ObservableObject {

    @Published private(set) var items = [MenuItem]()
    @Published private(set) var isLoading = false

    func fetch() {
        isLoading = true
        Task {
            let newItems: [MenuItem] = [.init(id: nil, title: "Mock", description: "Mock")]
            try! await Task.sleep(for: .seconds(2))
            await MainActor.run {
                isLoading = false
                items = newItems
            }
        }
    }
}
