//
//  FuriganaConverterUITests.swift
//  FuriganaConverterUITests
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

@testable import FuriganaConverter
import XCTest

class FuriganaConverterUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDown() {
        app.terminate()
    }

    func test_initialState() {
        let table = app
            .children(matching: .window).element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element(boundBy: 2)
            .children(matching: .table).element
        let toolbar = app.toolbars["Toolbar"]
        let keyboardBotton = toolbar.buttons["Keyboard"]
        let clearButton = toolbar.buttons["Clear"]
        let convertButton = toolbar.buttons["Convert"]
        XCTAssertTrue(table.exists)
        XCTAssertTrue(keyboardBotton.isEnabled)
        XCTAssertFalse(clearButton.isEnabled)
        XCTAssertFalse(convertButton.isEnabled)
    }

    var inputArea: XCUIElement {
        app
            .children(matching: .window).element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .textView).element
    }

    func test_inputState() {
        let inputArea = self.inputArea
        inputArea.tap()
        let closeKeyboardButton = app.toolbars["Toolbar"].buttons["keyboard.chevron.compact.down"]
        XCTAssertTrue(closeKeyboardButton.isHittable)
    }

    func test_readyToConvertState() {
        let inputArea = self.inputArea
        inputArea.tap()
        inputArea.typeText("漢字が混ざっている文章")
        let toolbar = app.toolbars["Toolbar"]
        let clearButton = toolbar.buttons["Clear"]
        let convertButton = toolbar.buttons["Convert"]
        XCTAssertTrue(clearButton.isEnabled)
        XCTAssertTrue(convertButton.isEnabled)
    }

    func test_tapSettingButton_showSetting() {
        app.navigationBars.buttons["slider.horizontal.3"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
