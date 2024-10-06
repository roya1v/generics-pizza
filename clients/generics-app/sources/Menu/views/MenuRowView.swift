import GenericsUI
import SharedModels
import SwiftUI

struct MenuRowView: View {

    let item: MenuFeature.State.Item
    let action: () -> Void

    var body: some View {
        HStack {
            getImage(for: item)
            VStack(alignment: .leading) {
                Text(item.item.title)
                    .font(.headline)
                Text(item.item.description)
                    .font(.gCaption)
                    .foregroundStyle(.secondary)
                Button {
                    action()
                } label: {
                    Text(item.item.formattedPrice())
                        .font(.caption)
                }
                .buttonStyle(GPrimaryButtonStyle())
            }
        }
    }

    func getImage(for item: MenuFeature.State.Item) -> some View {
        if let image = item.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 75.0)
        } else {
            Image("pizzza_placeholder")
                .resizable()
                .scaledToFit()
                .frame(width: 75.0)
        }
    }
}
