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
