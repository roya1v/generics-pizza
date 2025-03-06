import ArgumentParser

extension Bot {
    struct Actor: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create a bot that acts like someone",
            subcommands: [Restaurant.self, Customer.self, Driver.self]
        )
    }
}
