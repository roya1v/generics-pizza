import ComposableArchitecture
import GenericsCore
import SharedModels
import SwiftUI

struct NowView: View {

    let store: StoreOf<NowFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.connectionState {
                case .connecting:
                    ProgressView()
                case .failure(let message):
                    Text(message)
                case .success:
                    List {
                        Section("Orders") {
                            ForEach(store.state.orders) { order in
                                OrderListRowView(order: order) {
                                    store.send(
                                        .update(orderId: order.id!, state: order.state!.next()))
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}

extension OrderModel.State {
    func next() -> Self {
        switch self {
        case .new:
            .inProgress
        case .inProgress:
            .readyForDelivery
        case .readyForDelivery:
            .inDelivery
        case .inDelivery:
            .finished
        case .finished:
            fatalError()
        }
    }
}
