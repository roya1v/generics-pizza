import SwiftUI
import SharedModels

struct OrderListRowView: View {

    let order: OrderModel
    let onTap: (() -> Void)?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("ID: \(order.id!.uuidString)")
                    .font(.caption)
                Text(order.createdAt!, style: .time)
                    .font(.caption)
                let items = order.items.reduce("", {$0 + "\($1.menuItem.title) X\($1.count), "})
                Text("**Items:** \(items)")
                switch order.destination {
                case .delivery(let address):
                    Text("Delivery address: \(address)")
                case .pickUp:
                    Text("Self pick up order")
                }

            }
            Spacer()
            if let onTap {
                Button(order.state!.rawValue) {
                    onTap()
                }
            }
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    OrderListRowView(
        order: OrderModel(
            id: UUID(),
            createdAt: .now,
            items: [
                OrderModel.Item(
                    menuItem: MenuItem(
                        id: nil,
                        title: "Preview pizza",
                        description: "",
                        price: 999,
                        isHidden: false,
                        category: nil
                    ),
                    count: 3
                ),
                OrderModel.Item(
                    menuItem: MenuItem(
                        id: nil,
                        title: "Other preview pizza",
                        description: "",
                        price: 699,
                        isHidden: false,
                        category: nil
                    ),
                    count: 1
                ),
            ],
            state: .inProgress,
            destination: .pickUp
        )
    ) {

    }
}
