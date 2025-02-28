import ComposableArchitecture
import GenericsCore
import SharedModels
import SwiftUI
import Charts

struct InsightsView: View {

    let store: StoreOf<InsightsFeature>

    var body: some View {
        WithPerceptionTracking {
            Text("Most sold items")
            Chart {
                ForEach(store.itemsSales) {
                    BarMark(x: .value("Item name", $0.itemName), y: .value("Number of orders", $0.count))
                }
            }
            .padding()
        }
        .task {
            store.send(.shown)
        }
    }
}
