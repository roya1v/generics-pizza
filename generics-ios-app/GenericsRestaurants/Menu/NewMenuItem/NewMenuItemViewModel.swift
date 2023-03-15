//
//  NewMenuItemViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 15/03/2023.
//

import Foundation
import GenericsModels
import Factory

final class NewMenuItemViewModel: ObservableObject {

    @Injected(Container.menuRepository) private var menuRepository
    @Injected(Container.authenticationRepository) private var authRepository

    func createMenuItem(title: String, description: String, price: String) {
        menuRepository.authDelegate = authRepository

        let item = MenuItem(id: nil, title: title, description: description)
        Task {
            try! await menuRepository.create(item: item)
        }
    }
}
