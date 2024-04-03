//
//  File.swift
//  
//
//  Created by Mike S. on 03/04/2024.
//
import Foundation
import Factory

fileprivate let url = "http://localhost:8080"

extension Container {
    public var orderRepository: Factory<OrderRepository> {
        self { buildOrderRepository(url: url) }
            .singleton
    }

    public var menuRepository: Factory<MenuRepository> {
        self { buildMenuRepository(url: url) }
            .singleton
    }
}
