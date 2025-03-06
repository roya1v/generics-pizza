import ArgumentParser

extension Bot {
    struct Scenario: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Create all bots for a specific scenario",
            subcommands: [TestingDriverApp.self]
        )
    }
}
