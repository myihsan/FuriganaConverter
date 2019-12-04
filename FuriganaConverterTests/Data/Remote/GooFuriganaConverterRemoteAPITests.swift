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

    var session: URLSession!
    var sut: GooFuriganaConverterRemoteAPI!

    override func setUp() {
        session = MockURLSession()
        sut = GooFuriganaConverterRemoteAPI(session: session)
    }

    override func tearDown() {
        session = nil
        sut = nil
    }

    func test_conformsToFuriganaConverterRemoteAPI() {
        XCTAssertTrue((sut as AnyObject) is FuriganaConverterRemoteAPI)
    }

    func test_init_setsSession() {
        XCTAssertEqual(sut.session, session)
    }

    func test_init_setsRequestURL() throws {
        // given
        let requestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!

        // when
        let mockTask = try XCTUnwrap(sut.convert("") { _ in } as? MockURLSessionDataTask)

        // then
        XCTAssertEqual(mockTask.request.url, requestURL)
    }
}
