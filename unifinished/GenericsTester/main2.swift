//
//  main.swift
//  GenericsTester
//
//  Created by Mike S. on 12/10/2023.
//

import Foundation

let url = "http://localhost:8080"

protocol TestShortcut {
    var name: String { get }
    func perform() async throws
}

@main
struct GenericsTester {

    static let macros: [TestShortcut] = [
        MakeOrderShortcut(),
        MakeDriverOfferShortcut()
    ]

    static func main() async throws {
        print("Welcome to Generics Tester!")
        print("Please choose a test shortcut:")
        for (index, macro) in macros.enumerated() {
            print("\(index) - \(macro.name)")
        }
        print("\nEnter number and press return:")
        guard let input = readLine(), let index = Int(input) else {
            return
        }
        try await macros[index].perform()
    }
}
