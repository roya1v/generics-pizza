//
//  NowViewModelTests.swift
//  GenericsRestaurantsTests
//
//  Created by Mike S. on 19/12/2023.
//

import XCTest
@testable import GenericsRestaurants
@testable import GenericsCore
import Factory

@MainActor
final class NowViewModelTests: XCTestCase {
    var sut: NowViewModel!
    
    override func setUp() {
        sut = NowViewModel()
    }
}
