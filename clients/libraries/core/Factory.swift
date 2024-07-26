//
//  File.swift
//  
//
//  Created by Mike S. on 03/04/2024.
//
import Foundation
import Factory

extension Container {

    public var serverUrl: Factory<String> {
        self { "http://localhost:8080" }
    }

    public var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: self.serverUrl()) }
            .singleton
    }
}
