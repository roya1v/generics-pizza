import GenericsUI
import SwiftUI
import ComposableArchitecture
import SharedModels

struct MenuHeaderView: View {

    @State var selected: MenuItem.Category?

    let store: StoreOf<MenuFeature>

    var body: some View {
        ScrollView(
            .horizontal,
            showsIndicators: false
        ) {
            HStack {
                ForEach(store.categories) { category in
                    Button(category.name) {
                        selected = category
                    }
                    .buttonStyle(
                        GLinkButtonStyle(
                            style: selected == category
                                ? .active
                                : .inactive)
                    )
                    .padding(.gNormal)
                }
            }
        }
    }
}
