//
//  GenericsAppUITests.swift
//  GenericsAppUITests
//
//  Created by Mike S. on 06/08/2025.
//

import XCTest

final class GenericsAppUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.

    }
}
