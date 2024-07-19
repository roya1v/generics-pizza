//
//  MenuHeaderView.swift
//  GenericsApp
//
//  Created by Mike S. on 01/02/2023.
//

import SwiftUI

struct MenuHeaderView: View {
    
    var body: some View {
        ScrollView(.horizontal,
                   showsIndicators: false) {
            HStack {
                Button("Sets") {
                    print("Test")
                }
                .padding(8.0)
                Button("Pizza") {
                    print("Test")
                }
                .padding(8.0)
                Button("Drinks") {
                    print("Test")
                }
                .padding(8.0)
                Button("Alcohol") {
                    print("Test")
                }
                .padding(8.0)
                Button("Deserts") {
                    print("Test")
                }
                .padding(8.0)
                Button("Other") {
                    print("Test")
                }
                .padding(8.0)
            }
        }
    }
}

#Preview {
    MenuHeaderView()
}
