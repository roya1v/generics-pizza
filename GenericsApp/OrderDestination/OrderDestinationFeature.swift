import Combine
import ComposableArchitecture
import Factory
import Foundation
import GenericsCore
import SharedModels

@Reducer
struct OrderDestinationFeature {
    @ObservableState
    struct State: Equatable {
        @Shared var destination: OrderModel.Destination
        var picker: PickerThing = .restaurant
        var confirmActive = false
        var deliveryForm: DeliveryFormFeature.State?

        enum PickerThing {
            case restaurant
            case delivery
        }
    }

    enum Action {
        case appeared
        case dismissTapped
        case confirmTapped
        case deliveryForm(DeliveryFormFeature.Action)
        case pickerChanged(State.PickerThing)
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .appeared:
                switch state.destination {
                case .delivery(let address):
                    state.picker = .delivery
                    state.deliveryForm = DeliveryFormFeature.State(
                        street: address.street,
                        floor: "\(address.floor ?? 0)",
                        appartment: address.appartment ?? "",
                        comment: address.comment
                    )
                    state.confirmActive = true
                case .pickUp:
                    state.picker = .restaurant
                    state.deliveryForm = nil
                }
                return .none
            case .pickerChanged(let newValue):
                state.picker = newValue
                switch newValue {
                case .restaurant:
                    state.deliveryForm = nil
                    state.confirmActive = true
                case .delivery:
                    state.deliveryForm = DeliveryFormFeature.State(
                        street: "",
                        floor: "",
                        appartment: "",
                        comment: ""
                    )
                    state.confirmActive = false
                }
                return .none
            case .dismissTapped:
                return .none
            case .confirmTapped:
                if let address = state.deliveryForm {
                    state.destination = OrderModel.Destination.delivery(
                        OrderModel.Destination.Address(
                            street: address.street,
                            floor: Int(address.floor),
                            appartment: address.appartment,
                            comment: address.comment,
                            coordinates: .init(latitude: 0.0, longitude: 0.0)
                        )
                    )
                } else {
                    state.destination = .pickUp
                }
                return .none
            case .deliveryForm:
                return .none
            }
        }
        .ifLet(\.deliveryForm, action: \.deliveryForm) {
            DeliveryFormFeature()
        }
    }
}
