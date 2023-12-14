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

@MainActor
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
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        print(completion)
                    }, receiveValue: { message in
                        self.state = .ready
                        switch message {
                        case .newOrder(let order):
                            self.orders.insert(order, at: 0)
                        }
                    })
                    .store(in: &cancellable)
            } catch {
                state = .error
            }
        }
    }

    func update(_ order: OrderModel, to newState: OrderState) {
        Task {
            try? await repository.send(message: .update(orderId: order.id!, state: newState))
            if let index = orders.firstIndex(where: {$0.id == order.id}) {
                let newState = order.state?.next()
                guard newState != .finished else {
                    orders.remove(at: index)
                    return
                }
                orders[index] = OrderModel(id: order.id,
                                           createdAt: order.createdAt,
                                           items: order.items,
                                           state: newState)

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
