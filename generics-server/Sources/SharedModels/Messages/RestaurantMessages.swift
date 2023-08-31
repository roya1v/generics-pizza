//
//  RestaurantMessages.swift
//  
//
//  Created by Mike S. on 21/03/2023.
//

import Foundation

public enum RestaurantToServerMessage: Codable {
    case update(orderId: UUID, state: OrderState)
}

public enum RestaurantFromServerMessage: Codable {
    case newOrder(OrderModel)
}
