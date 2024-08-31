//
//  MenuRowView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI
import SharedModels
import clients_libraries_GenericsUI

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
        Group {
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
}
