import SwiftUI
import ComposableArchitecture
import SharedModels

struct TrackingView: View {

    let store: StoreOf<TrackingFeature>

    var body: some View {
        WithPerceptionTracking {
            VStack {
                title
                    .font(.largeTitle)
                HStack {
                    ForEach([OrderModel.State.new,
                             .inProgress,
                             .readyForDelivery,
                             .inDelivery,
                             .finished],
                            id: \.rawValue) { state in
                        WithPerceptionTracking {
                            RoundedRectangle(cornerRadius: 3.0)
                                .foregroundStyle(
                                    store.orderState == state
                                    ? Color.red
                                    : Color.gray
                                )
                                .frame(height: 4.0)
                        }
                    }
                }
                .padding()
            }

            .task {
                store.send(.appeared)
            }
        }
    }

    var title: some View {
        WithPerceptionTracking {
            switch store.orderState {
            case .new:
                Text("Restaurant is starting the order")
            case .inProgress:
                Text("The order is being prepared")
            case .readyForDelivery:
                Text("The order is waiting for a driver")
            case .inDelivery:
                Text("The order is being delivered")
            case .finished:
                Text("The order was delivered")
            default:
                Text("Loading")
            }
        }
    }
}
