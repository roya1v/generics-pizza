//
//  NewMenuItemView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/03/2023.
//

import SwiftUI

struct NewMenuItemView: View {

    let model = NewMenuItemViewModel()
    @State var title = ""
    @State var description = ""
    @State var price = ""
    
    var body: some View {
        VStack {
            Text("New Item")
                .font(.title)
            Form {
                TextField("Title", text: $title)
                TextField("Description", text: $description)
                TextField("Price", text: $price)
                Button("Create") {
                    model.createMenuItem(title: title,
                                         description: description,
                                         price: price)
                }
            }
        }
    }
}

struct NewMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewMenuItemView()
    }
}
