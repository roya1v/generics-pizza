//
//  CardView.swift
//  
//
//  Created by Mike Shevelinsky on 06/03/2023.
//

import SwiftUI

public struct CardView<Content>: View where Content: View {

    var content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
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
