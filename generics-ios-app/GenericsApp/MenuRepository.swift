//
//  MenuRepository.swift
//  GenericsApp
//
//  Created by Mike Shevelinsky on 02/02/2023.
//

import Foundation

import Factory

extension Container {
    static let menuRepository = Factory { MenuRepository() }
}

class MenuRepository {

    private let baseURL = URL(string: "http://localhost:8080")!

    func fetchMenu() async throws {

    }
}
