//
//  CustomerMessage.swift
//  
//
//  Created by Mike S. on 31/08/2023.
//

import Foundation

public enum CustomerFromServerMessage: Codable {
    case accepted
    case newState(OrderState)
}
