import SwiftUI
import ComposableArchitecture
import GenericsUI

@Reducer
struct DetailsTileFeature {
    @ObservableState
    enum State: Equatable {
        case idle
        case offerOrder(details: String)
        case delivering(details: String)
    }

    enum Action {
        case buttonTapped
    }
}

struct DetailsTile: View {

    @Bindable
    var store: StoreOf<DetailsTileFeature>

    var body: some View {
        VStack {
            switch store.state {
            case .idle:
                Text("Waiting for new order")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
            case .offerOrder(let details):
                Text("New order")
                    .font(.largeTitle)
                Text(details)
                Button("Accept") {
                    store.send(.buttonTapped)
                }
                .buttonStyle(GPrimaryButtonStyle())
            case .delivering(let details):
                Text("New order")
                    .font(.largeTitle)
                Text(details)
                Button("Delivered") {
                    store.send(.buttonTapped)
                }
                .buttonStyle(GPrimaryButtonStyle())
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: .gM)
                .fill(.background)
        }
    }
}
