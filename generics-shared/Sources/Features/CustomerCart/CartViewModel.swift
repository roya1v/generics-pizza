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

@MainActor
final class CartViewModel: ObservableObject {

    enum State: Equatable {
        case needItems
        case readyForOrder
        case loadingOrderDetails
        case loading
        case inOrderState(state: OrderState)
        case error
    }

    @Published var isPickUp = true
    @Published var address: String = ""
    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var subtotal: [SubtotalModel] = []
    @Published private(set) var state: State = .needItems

    @Injected(\.orderRepository)
    private var repository

    @Injected(\.menuRepository)
    private var menuRepository

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        items = repository.items
        state = .loadingOrderDetails
        ThrowingAsyncTask {
            try await self.repository.checkPrice()
        } onResult: { subtotal in
            self.subtotal = subtotal
            self.state = .readyForOrder
        } onError: { error in
            self.state = .error
        }
    }

    func placeOrder() {
        state = .loading
        if !isPickUp && address.isEmpty {
            return
        }
        repository.orderType = isPickUp ? .pickUp : .delivery(address: address)
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
        repository.remove(item: item)
        items = repository.items
    }

    func imageUrl(for item: MenuItem) -> URL? {
        menuRepository.imageUrl(for: item)
    }
}

extension MenuItem {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(price) / 100)
    }
}

extension SubtotalModel {
    func formattedPrice() -> String {
        String(format: "%.2f$", Double(value) / 100)
    }
}
