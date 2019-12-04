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

    let requestURL = URL(string: "https://example.com/api/hiragana")!

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
        let actualRequestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!

        // when
        let mockTask = try XCTUnwrap(sut.convert("") { _ in } as? MockURLSessionDataTask)

        // then
        XCTAssertEqual(mockTask.request.url, actualRequestURL)
    }

    func test_convert_setsExpectedBody() throws {
        // given
        let privateInfosPath = Bundle.main.path(forResource: "PrivateInfo", ofType: "plist")!
        let privateInfos = NSDictionary(contentsOfFile: privateInfosPath)!
        let appID = try XCTUnwrap(privateInfos["AppID"] as? String)

        let japaneseString = "漢字が混ざっている文章"

        let expectedBodyJSONObject = [
            "app_id": appID,
            "sentence": japaneseString,
            "output_type": "hiragana"
        ]

        // when
        let mockTask = try XCTUnwrap(sut.convert(japaneseString) { _ in } as? MockURLSessionDataTask)
        let httpBody = try  XCTUnwrap(mockTask.request.httpBody)
        let httpBodyJSONObject = try JSONSerialization.jsonObject(with: httpBody) as? [String: String]

        // then
        XCTAssertEqual(httpBodyJSONObject, expectedBodyJSONObject)
    }

    func test_convert_callsResumesOnTask() throws {
        // when
        let mockTask = try XCTUnwrap(sut.convert("") { _ in } as? MockURLSessionDataTask)

        // then
        XCTAssertTrue(mockTask.calledResume)
    }

    func test_convert_givenFailureResponseWithUndecodableBody_callsCompletionWithUnknown() throws {
        // when
        let result = try whenConvert(data: nil, statusCode: 500, error: nil)

        // then
        XCTAssertEqual(result, .failure(.unknown))
    }
}

extension GooFuriganaConverterRemoteAPITests {

    func whenConvert(
        data: Data? = nil,
        statusCode: Int = 200,
        error: Error? = nil
    ) throws -> RemoteAPIResult? {
        let response = HTTPURLResponse(
            url: requestURL,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )

        // when
        var receivedResult: RemoteAPIResult?

        let mockTask = try XCTUnwrap(sut.convert("") { result in
            receivedResult = result
            } as? MockURLSessionDataTask)
        mockTask.completionHandler(data, response, error)

        return receivedResult
    }
}
