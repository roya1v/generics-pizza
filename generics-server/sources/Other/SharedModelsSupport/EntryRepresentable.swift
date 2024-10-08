import Fluent

protocol EntryRepresentable {
    associatedtype Entry: Model

    func toEntry() -> Entry
}
