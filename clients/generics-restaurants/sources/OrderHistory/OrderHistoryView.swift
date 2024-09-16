import SwiftUI
import ComposableArchitecture
import SharedModels
import clients_libraries_GenericsCore

struct OrderHistoryView: View {

    let store: StoreOf<OrderHistoryFeature>

    var body: some View {
        WithPerceptionTracking {
            Group {
                switch store.state {
                case .loading:
                    ProgressView()
                case .loaded(let items):
                    List {
                        ForEach(items) { order in
                            OrderListRowView(order: order, onTap: nil)
                        }
                    }
                case .error(let message):
                    Text(message)
                }
            }
            .onAppear {
                store.send(.shown)
            }
        }
    }
}
