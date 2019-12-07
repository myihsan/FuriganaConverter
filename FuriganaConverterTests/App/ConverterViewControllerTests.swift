//
//  ConverterViewControllerTests.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

@testable import FuriganaConverter
import XCTest

class ConverterViewControllerTests: XCTestCase {

    class MockConverterUserInterfaceView: UIView, ConverterUserInterface {

        var selectedType: ConverterOutputType = .hiragana
        var result: String?

        func setResult(_ result: String) {
            self.result = result
        }
    }

    var userInterface: MockConverterUserInterfaceView!
    var remoteAPI: MockFuriganaConverterRemoteAPI!
    var sut: ConvertorViewController!

    override func setUp() {
        userInterface = MockConverterUserInterfaceView()
        remoteAPI = MockFuriganaConverterRemoteAPI()
        sut = ConvertorViewController(userInterface: userInterface, remoteAPI: remoteAPI)
    }

    override func tearDown() {
        userInterface = nil
        remoteAPI = nil
        sut = nil
    }

    func test_conformsToConverterEventResponder() {
        XCTAssertTrue((sut as AnyObject) is ConverterEventResponder)
    }

    func test_convert_callsRemoteAPI() {
        // when
        sut.convert("")

        // then
        XCTAssertEqual(remoteAPI.convertCallCount, 1)
    }

    func test_convert_callsRemoteAPI_onceIn300Millisecond() {
        let convertBefore300MillisecondExpetation = expectation(description: "Before")
        let convertAfter300MillisecondExpetation = expectation(description: "After")

        // when
        sut.convert("")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.sut.convert("")
            convertBefore300MillisecondExpetation.fulfill()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.sut.convert("")
            convertAfter300MillisecondExpetation.fulfill()
        }

        // then
        wait(for: [convertBefore300MillisecondExpetation], timeout: 0.25)
        XCTAssertEqual(self.remoteAPI.convertCallCount, 1)
        wait(for: [convertAfter300MillisecondExpetation], timeout: 0.15)
        XCTAssertEqual(self.remoteAPI.convertCallCount, 2)
    }

    func test_convert_givenSuccess_callsSetResult() {
        // given
        let expectedResult = "かんじが まざっている ぶんしょう"
        remoteAPI.result = .success(expectedResult)

        // when
        sut.convert("")

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }
}
