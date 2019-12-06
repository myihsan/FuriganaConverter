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

    func test_conformsToConverterEventResponder() {
        XCTAssertTrue((sut as AnyObject) is ConverterEventResponder)
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
