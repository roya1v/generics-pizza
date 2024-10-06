import ArgumentParser
import Foundation
import GenericsCore
import SwiftlyHttp

let baseUrl = "http://localhost:8080"

@main
struct Bot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A set of bots for generics pizza.",
        subcommands: [Restaurant.self],
        defaultSubcommand: Restaurant.self
    )
}
