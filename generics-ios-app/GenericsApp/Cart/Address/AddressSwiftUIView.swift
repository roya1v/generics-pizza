//
//  AddressSwiftUIView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 08/05/2023.
//

import SwiftUI

struct AddressSwiftUIView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentationMode


    func makeUIViewController(context: Context) -> AddressViewController {
        let vc = AddressViewController()

        vc.popMe = {
            self.presentationMode.wrappedValue.dismiss()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: AddressViewController, context: Context) {

    }
}

struct AddressSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSwiftUIView()
            .ignoresSafeArea()
    }
}
