import SwiftUI
import ComposableArchitecture

struct CartTotalView: View {

    let store: StoreOf<CartFeature>

    var body: some View {
        WithPerceptionTracking {
            ForEach(store.subtotal, id: \.name) { part in
                WithPerceptionTracking {
                    if part.isSecondary {
                        HStack {
                            Text(part.name)
                            Spacer()
                            Text(part.formattedPrice())
                        }
                        .foregroundColor(Color.gray)
                        .font(.gCaption)
                    } else {
                        Divider()
                        HStack {
                            Text(part.name)
                            Spacer()
                            Text(part.formattedPrice())
                        }
                    }
                }
            }
        }
    }
}
