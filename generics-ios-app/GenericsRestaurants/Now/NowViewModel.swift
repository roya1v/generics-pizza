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

    @Injected(Container.orderRestaurantRepository)
    private var repository

    @Injected(Container.authenticationRepository)
    private var authRepository

    private var cancellable = Set<AnyCancellable>()

    func fetch() {
        state = .loading
        repository.authDelegate = authRepository
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
                        case .update(let id, let state):
                            let order = self.orders.first(where: { $0.id == id })
                            self.orders.removeAll(where: { $0.id == id })
                            if state != .finished {
                                self.orders.append(.init(id: order?.id, createdAt: order?.createdAt, items: order?.items ?? [], state: state))
                                self.orders.sort { $0.createdAt!.timeIntervalSince1970 > $1.createdAt!.timeIntervalSince1970 }
                            }
                        case .accepted:
                            print("wow")
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
            try? await repository.send(message: .update(id: order.id!, state: newState))
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
