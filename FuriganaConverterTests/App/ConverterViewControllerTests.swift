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
        var result: String? {
            get {
                if case let .result(_, resultViewState) = state,
                    case let .result(currentResult) = resultViewState {
                    return currentResult
                } else {
                    return nil
                }
            }
            set {
                if let newValue = newValue {
                    state = .result(resultViewState: .result(newValue))
                }
            }
        }
        var state: ConverterUserInterfaceState = .history

        func changeState(_ state: ConverterUserInterfaceState) {
            self.state = state
        }
    }

    var userInterface: MockConverterUserInterfaceView!
    var remoteAPI: MockFuriganaConverterRemoteAPI!
    var coreDataStack: MockCoreDataStack!
    var historyHolder: MockHistoryHolder!
    var sut: ConverterViewController!

    override func setUp() {
        userInterface = MockConverterUserInterfaceView()
        remoteAPI = MockFuriganaConverterRemoteAPI()
        coreDataStack = MockCoreDataStack()
        historyHolder = MockHistoryHolder()
        sut = ConverterViewController(
            userInterface: userInterface,
            remoteAPI: remoteAPI,
            coreDataStack: coreDataStack,
            historyHolder: historyHolder
        ) {
            UIViewController()
        }
    }

    override func tearDown() {
        userInterface = nil
        remoteAPI = nil
        coreDataStack = nil
        historyHolder = nil
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

    func test_covert_givenJapaneseStringExistInHistoryAndHiraganaSelected_usesHistory() {
        // given
        let history = givenHistory()
        userInterface.selectedType = .hiragana

        // when
        sut.convert(history.originalString)

        // then
        verifyNoRemoteAPICallsAndSetsResult(history.convertedString)
    }

    func test_covert_givenJapaneseStringExistInHistoryAndKataganaSelected_usesHistory() {
        // given
        let history = givenHistory()
        userInterface.selectedType = .katakana

        // when
        sut.convert(history.originalString)

        // then
        verifyNoRemoteAPICallsAndSetsResult("カンジガ マザッテイル ブンショウ")
    }

    func test_didSelectHistory_givenKatakanaSelected_convertsToHiragana() {
        // given
        let history = givenHistory()
        userInterface.selectedType = .katakana

        // when
        sut.didSelect(history)

        // then
        verifyNoRemoteAPICallsAndSetsResult("カンジガ マザッテイル ブンショウ")
    }

    private func givenHistory() -> History {
        let japaneseString = "漢字が混ざっている文章"
        let expectedResult = "かんじが まざっている ぶんしょう"
        let history = History(context: coreDataStack.persistentContainer.viewContext)
        history.originalString = japaneseString
        history.convertedString = expectedResult
        historyHolder.histories = [history]
        return history
    }

    private func verifyNoRemoteAPICallsAndSetsResult(_ result: String) {
        XCTAssertEqual(remoteAPI.convertCallCount, 0)
        XCTAssertEqual(userInterface.result, result)
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

    func test_didSelectOutputTypes_givenNotShowingResult_keepsState() {
        // given
        let state: ConverterUserInterfaceState = .history
        userInterface.state = state

        ConverterOutputType.allCases.forEach { type in
            // when
            sut.didSelect(type)

            // then
            XCTAssertEqual(userInterface.state, state)
        }
    }
}
