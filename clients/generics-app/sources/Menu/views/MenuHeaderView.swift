import GenericsUI
import SwiftUI
import ComposableArchitecture
import SharedModels

struct MenuHeaderView: View {

    let store: StoreOf<MenuFeature>

    var body: some View {
        WithPerceptionTracking {
            ScrollView(
                .horizontal,
                showsIndicators: false
            ) {
                HStack {
                    ForEach(store.categories) { category in
                        Button(category.name) {
                            store.send(.didSelectCategory(category.id!))
                        }
                        .buttonStyle(
                            GLinkButtonStyle(
                                style: store.selectedCategory == category
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
