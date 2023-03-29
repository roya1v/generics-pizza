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

    enum State {
        case readyForOrder
        case loading
        case inOrderState(state: OrderState)
    }

    @Published private(set) var items = [MenuItem]()
    @Published private(set) var state: State = .readyForOrder

    @Injected(Container.orderRepository) private var repository
    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        items = repository.items
    }

    func placeOrder() {
        state = .loading
        Task {
            try! await repository.placeOrder()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] message in
                    switch message {
                    case .update(_, let newState):
                        self?.state = .inOrderState(state: newState)
                    default:
                        fatalError("Not implemented")
                    }
                }
                .store(in: &cancellable)
        }
    }
}
