//
//  CardView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 01/02/2023.
//

import SwiftUI

struct CardView<Content>: View where Content: View {

    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .background(.white)
            .compositingGroup()
            .cornerRadius(16.0)
            .shadow(radius: 8.0)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView {
            Text("Demo")
                .padding()
        }
    }
}
