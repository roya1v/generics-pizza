//
//  CartViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import GenericsModels
import Factory
import Combine

final class CartViewModel: ObservableObject {
    @Published var items = [MenuItem]()

    @Injected(Container.orderRepository) var repository

    private var cancellable = Set<AnyCancellable>()

    @Published var events = [String]()

    func fetch() {
        items = repository.items
    }

    func placeOrder() {
        Task {
            try! await repository.placeOrder()
                .receive(on: DispatchQueue.main)
                .sink { text in
                    self.events.append(text)
                }
                .store(in: &cancellable)
        }
    }
}
