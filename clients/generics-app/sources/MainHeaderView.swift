//
//  MainHeaderView.swift
//  GenericsApp
//
//  Created by Mike S. on 19/07/2024.
//

import SwiftUI
import clients_libraries_GenericsUI

struct MainHeaderView: View {

    public var body: some View {
        HStack {
            Circle()
                .fill(Color.white)
                .frame(width: 40.0, height: 40.0)
            VStack {
                HStack {
                    Text("New York, Bakers str. 123")
                    Image(systemName: "chevron.down")
                        .foregroundStyle(Color.gAccent)

                }
                Text("Free delivery in 35 min")
                    .font(.gCaption)
            }
            Spacer()
            Circle()
                .fill(Color.white)
                .frame(width: 40.0, height: 40.0)
        }
    }
}
