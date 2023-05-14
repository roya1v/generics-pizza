//
//  AddressSwiftUIView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 08/05/2023.
//

import SwiftUI

struct AddressSwiftUIView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var dumbFix: Bool


    func makeUIViewController(context: Context) -> AddressViewController {
        let vc = AddressViewController()
        dumbFix = true

        vc.popMe = {
            dumbFix = false
            self.dismiss()
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: AddressViewController, context: Context) {

    }
}

struct AddressSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        AddressSwiftUIView(dumbFix: .constant(true))
            .ignoresSafeArea()
    }
}
