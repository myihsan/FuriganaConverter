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
        var result: String = ""
    }

    var userInterface: MockConverterUserInterfaceView!
    var remoteAPI: MockFuriganaConverterRemoteAPI!
    var coreDataStack: MockCoreDataStack!
    var sut: ConvertorViewController!

    override func setUp() {
        userInterface = MockConverterUserInterfaceView()
        remoteAPI = MockFuriganaConverterRemoteAPI()
        coreDataStack = MockCoreDataStack()
        sut = ConvertorViewController(userInterface: userInterface, remoteAPI: remoteAPI, coreDataStack: coreDataStack)
    }

    override func tearDown() {
        userInterface = nil
        remoteAPI = nil
        coreDataStack = nil
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

    func test_convert_givenHiraganaSelectedAndSuccess_callsSetResultWithHiragana() {
        // given
        let expectedResult = "かんじが まざっている ぶんしょう"
        userInterface.selectedType = .hiragana
        remoteAPI.result = .success(expectedResult)

        // when
        sut.convert("")

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }

    func test_convert_givenKatakanaSelectedAndSuccess_callsSetResultWithKatakana() {
        // given
        let result = "かんじが まざっている ぶんしょう"
        let expectedResult = "カンジガ マザッテイル ブンショウ"
        userInterface.selectedType = .katakana
        remoteAPI.result = .success(result)

        // when
        sut.convert("")

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }

    func test_didSelectHiragana_givenHiraganaResult_keepsHiragana() {
        // give
        let expectedResult = "かんじが まざっている ぶんしょう"
        userInterface.result = expectedResult

        // when
        sut.didSelect(.hiragana)

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }

    func test_didSelectHiragana_givenKatakanaResult_convertsToHiragana() {
        // give
        let result = "カンジガ マザッテイル ブンショウ"
        let expectedResult = "かんじが まざっている ぶんしょう"
        userInterface.result = result

        // when
        sut.didSelect(.hiragana)

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }

    func test_didSelectKatakana_givenKatakanaResult_keepsKatakana() {
        // give
        let result = "カンジガ マザッテイル ブンショウ"
        userInterface.result = result

        // when
        sut.didSelect(.katakana)

        // then
        XCTAssertEqual(userInterface.result, result)
    }

    func test_didSelectKatagana_givenHiraganaResult_convertsToKatakana() {
        // give
        let result = "かんじが まざっている ぶんしょう"
        let expectedResult = "カンジガ マザッテイル ブンショウ"
        userInterface.result = result

        // when
        sut.didSelect(.katakana)

        // then
        XCTAssertEqual(userInterface.result, expectedResult)
    }
}
