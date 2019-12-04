//
//  GooFuriganaConverterRemoteAPITests.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

@testable import FuriganaConverter
import XCTest

class GooFuriganaConverterRemoteAPITests: XCTestCase {

    var sut: GooFuriganaConverterRemoteAPI!

    override func setUp() {
        sut = GooFuriganaConverterRemoteAPI()
    }

    override func tearDown() {
        sut = nil
    }

    func test_conformsToFuriganaConverterRemoteAPI() {
        XCTAssertTrue((sut as AnyObject) is FuriganaConverterRemoteAPI)
    }

    func test_init_setsRequestURL() {
        // given
        let requestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!

        // then
        XCTAssertEqual(sut.requestURL, requestURL)
    }
}