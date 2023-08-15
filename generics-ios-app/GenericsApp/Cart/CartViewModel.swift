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
        case error
    }

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var subtotal: [SubtotalModel] = []
    @Published private(set) var state: State = .readyForOrder

    @Injected(Container.orderRepository)
    private var repository

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        items = repository.items
        Task {
            if let total = try? await repository.checkPrice() {
                DispatchQueue.main.async {
                    self.subtotal = total
                }
            }
        }
    }

    func placeOrder() {
        state = .loading
        Task {
            do {
                try await repository.placeOrder()
                    .assertNoFailure()
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
            } catch {
                state = .error
            }
        }
    }

    func remove(_ item: MenuItem) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
}

extension MenuItem: Equatable {
    public static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        lhs.id == rhs.id
    }
}
