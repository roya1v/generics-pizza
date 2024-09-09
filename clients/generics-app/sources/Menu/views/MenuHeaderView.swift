import SwiftUI
import clients_libraries_GenericsUI

struct MenuHeaderView: View {

    private let items = [
        "Sets",
        "Pizza",
        "Drinks",
        "Alcohol",
        "Deserts",
        "Other"
    ]

    @State var selected = "Sets"

    var body: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            HStack {
                ForEach(items, id: \.self) { item in
                    Button(item) {
                        selected = item
                    }
                    .buttonStyle(GLinkButtonStyle(
                        style: selected == item
                        ? .active
                        : .inactive))
                    .padding(.gNormal)
                }
            }
        }
    }
}
