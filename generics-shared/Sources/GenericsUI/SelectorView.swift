//
//  SwiftUIView.swift
//  
//
//  Created by Mike S. on 14/05/2023.
//

import SwiftUI

public struct SelectorView: View {

    let caption: String
    let icon: String
    let text: String

    public init(caption: String, icon: String, text: String) {
        self.caption = caption
        self.icon = icon
        self.text = text
    }

    public var body: some View {
        VStack(alignment: .leading) {
            Text(caption)
                .font(.genericsCaption)
                .foregroundColor(Color.gray)
                .padding(1.0)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color.gray)
                Text(text)
                    .lineLimit(1)
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SelectorView(caption: "",
                     icon: "",
                     text: "")
    }
}
