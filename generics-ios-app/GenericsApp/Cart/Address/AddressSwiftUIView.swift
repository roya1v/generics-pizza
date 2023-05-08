//
//  AddressSwiftUIView.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 08/05/2023.
//

import SwiftUI

struct AddressSwiftUIView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AddressViewController {
        return AddressViewController()
    }

    func updateUIViewController(_ uiViewController: AddressViewController, context: Context) {

    }
}
