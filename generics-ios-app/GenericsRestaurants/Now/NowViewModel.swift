//
//  NowViewModel.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 29/03/2023.
//

import Foundation
import Factory
import SharedModels
import Combine
import GenericsUI

final class NowViewModel: ObservableObject {

    @Published private(set) var state: ViewState = .ready
    @Published private(set) var orders: [OrderModel] = []

    @Injected(\.orderRestaurantRepository)
    private var repository

    @Injected(\.authenticationRepository)
    private var authRepository

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        state = .loading
        repository.authFactory = { try? self.authRepository.getAuthentication() }
        Task {
            do {
                try await repository
                    .getFeed()
                    .assertNoFailure()
                    .receive(on: DispatchQueue.main)
                    .sink { message in
                        self.state = .ready
                        switch message {
                        case .newOrder(let order):
                            self.orders.insert(order, at: 0)
                        }
                    }
                    .store(in: &cancellable)
            } catch {
                state = .error
            }
        }
    }

    func update(_ order: OrderModel, to newState: OrderState) {
        Task {
            try? await repository.send(message: .update(orderId: order.id!, state: newState))
            let order = self.orders.first(where: { $0.id == order.id })
            self.orders.removeAll(where: { $0.id == order?.id})
            if newState != .finished {
                self.orders.append(.init(id: order?.id, createdAt: order?.createdAt, items: order?.items ?? [], state: newState))
                self.orders.sort { $0.createdAt!.timeIntervalSince1970 > $1.createdAt!.timeIntervalSince1970 }
            }
        }
    }
}

extension OrderState {
    func next() -> Self {
        switch self {
        case .new:
            return .inProgress
        case .inProgress:
            return .readyForDelivery
        case .readyForDelivery:
            return .inDelivery
        case .inDelivery:
            return .finished
        case .finished:
            fatalError()
        }
    }
}
