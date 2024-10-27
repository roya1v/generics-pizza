import GenericsUI
import SwiftUI
import ComposableArchitecture
import SharedModels

struct MenuHeaderView: View {

    let store: StoreOf<MenuHeaderFeature>

    var body: some View {
        WithPerceptionTracking {
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack {
                    ForEach(store.categories) { category in
                        WithPerceptionTracking {
                            Button(category.name) {
                                store.send(.categorySelected(category.id), animation: .easeInOut)
                            }
                            .buttonStyle(
                                GLinkButtonStyle(
                                    style: store.selected == category
                                    ? .active
                                    : .inactive)
                            )
                            .padding(.gNormal)
                        }
                    }
                }
            }
        }
    }
}
