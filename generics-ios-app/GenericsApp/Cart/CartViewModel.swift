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
import CoreLocation
import GenericsHelpers

final class CartViewModel: ObservableObject {

    enum State: Equatable {
        case readyForOrder
        case loading
        case inOrderState(state: OrderState)
        case needAddress
        case error
    }

    @Published private(set) var items: [MenuItem] = []
    @Published private(set) var address: String?
    @Published private(set) var subtotal: [SubtotalModel] = []
    @Published private(set) var state: State = .readyForOrder

    @Injected(\.orderRepository)
    private var repository

    @Injected(\.geocodingService)
    private var geocodingService

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        items = repository.items
        ThrowingAsyncTask {
            return try await self.repository.checkPrice()
        } onResult: { subtotal in
            self.subtotal = subtotal
        } onError: { error in
            fatalError(error.localizedDescription)
        }
    }

    func checkAddress() {
        if state == .needAddress && repository.address != nil {
            state = .readyForOrder
        }

        if let address = repository.address {
            self.address = ""
            ThrowingAsyncTask {
                return try await self.geocodingService
                    .getAddress(for: address.coordinate.clLocationCoordinate2d)
            } onResult: { addressString in
                self.address = (addressString ?? "")  + address.details
            } onError: { error in
                fatalError(error.localizedDescription)
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
                        case let .newState(state):
                            self?.state = .inOrderState(state: state)
                        case .accepted:
                            fatalError()
                        }
                    }
                    .store(in: &cancellable)
            } catch {
                if let error = error as? OrderError {
                    switch error {
                    case .noAddress:
                        self.state = .needAddress
                    }
                    return
                }
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
