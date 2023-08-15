//
//  NewMenuItemView.swift
//  GenericsRestaurants
//
//  Created by Mike S. on 14/03/2023.
//

import SwiftUI

struct NewMenuItemView: View {

    @StateObject var model = NewMenuItemViewModel()
    @State var title = ""
    @State var description = ""
    @State var price = ""
    
    var body: some View {
        VStack {
            switch model.state {
            case .error:
                errorView
            default:
                Text("New Item")
                    .font(.title)
                Form {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                    TextField("Price", text: $price)
                    if model.isLoading {
                        ProgressView()
                    } else {
                        Button("Create") {
                            model.createMenuItem(title: title,
                                                 description: description,
                                                 price: price)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 300.0, height: 200.0)
    }

    var errorView: some View {
        VStack {
            Text("Error occirred!")
                .font(.title)
            Text(model.occurredError!.localizedDescription)
        }
    }
}

struct NewMenuItemView_Previews: PreviewProvider {
    static var previews: some View {
        NewMenuItemView()
    }
}
