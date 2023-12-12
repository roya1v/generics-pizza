//
//  CartViewModel.swift
//  GenericsApp
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation
import SharedModels
import Factory
import Combine
import GenericsCore
import GenericsHelpers

final class CartViewModel: ObservableObject {

    enum State: Equatable {
        case needItems
        case readyForOrder
        case loadingOrderDetails
        case loading
        case inOrderState(state: OrderState)
        case error
    }

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var subtotal: [SubtotalModel] = []
    @Published private(set) var state: State = .needItems

    @Injected(\.orderRepository)
    private var repository

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        items = repository.items
        state = .loadingOrderDetails
        ThrowingAsyncTask {
            try await self.repository.checkPrice()
        } onResult: { subtotal in
            self.subtotal = subtotal
        } onError: { error in
            self.state = .error
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
                        case let .newState(state):
                            self?.state = .inOrderState(state: state)
                        case .accepted:
                            fatalError()
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
