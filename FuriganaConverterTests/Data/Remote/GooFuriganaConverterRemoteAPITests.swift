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

    var session: MockURLSession!
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

    func test_init_setsRequestURL() {
        // given
        let actualRequestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!

        // when
        let mockTask = sut.convert("") { _ in } as! MockURLSessionDataTask // swiftlint:disable:this force_cast

        // then
        XCTAssertEqual(mockTask.request.url, actualRequestURL)
    }

    func test_convert_callsByPOST() {
        // when
        let mockTask = sut.convert("") { _ in } as! MockURLSessionDataTask // swiftlint:disable:this force_cast

        // then
        XCTAssertEqual(mockTask.request.httpMethod, "POST")
    }

    func test_convert_setsContentTypeToJSON() {
        // when
        let mockTask = sut.convert("") { _ in } as! MockURLSessionDataTask // swiftlint:disable:this force_cast

        // then
        let contentType = mockTask.request.allHTTPHeaderFields?["Content-Type"]
        XCTAssertEqual(contentType, "application/json")
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
        let mockTask = sut.convert(japaneseString) { _ in } as! MockURLSessionDataTask
        // swiftlint:disable:previous force_cast
        let httpBody = try XCTUnwrap(mockTask.request.httpBody)
        let httpBodyJSONObject = try JSONSerialization.jsonObject(with: httpBody) as? [String: String]

        // then
        XCTAssertEqual(httpBodyJSONObject, expectedBodyJSONObject)
    }

    func test_convert_callsResumesOnTask() {
        // when
        let mockTask = sut.convert("") { _ in } as! MockURLSessionDataTask // swiftlint:disable:this force_cast

        // then
        XCTAssertTrue(mockTask.calledResume)
    }

    func test_convert_givenError_callsCompletionWithUnknown() {
        // given
        let error = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorCannotConnectToHost,
            userInfo: nil
        )

        // when
        let result = verifyConvertDispatchedToMainWhen(error: error)

        // then
        XCTAssertEqual(result, .failure(.unknown))
    }

    func test_convert_givenCancelError_abortsConvert() {
        // given
        let error = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorCancelled,
            userInfo: nil
        )

        let expectation = self.expectation(description: "Completion wasn't called")
        expectation.isInverted = true

        let mockTask = sut.convert("") { _ in
            expectation.fulfill()
            } as! MockURLSessionDataTask
        // swiftlint:disable:previous force_cast
        mockTask.completionHandler(nil, nil, error)

        wait(for: [expectation], timeout: 0.2)
    }

    func test_convert_givenFailureResponseWithUndecodableBody_callsCompletionWithUnknown() {
        // when
        let result = verifyConvertDispatchedToMainWhen(statusCode: 500)

        // then
        XCTAssertEqual(result, .failure(.unknown))
    }

    func test_convert_givenFailureResponseWithUnexpectedMessage_callsCompletionWithUnexpected() {
        let unexpectedError: [(code: Int, message: String)] = [
            (400, "Content-Type is empty"),
            (400, "Invalid JSON"),
            (400, "Invalid Content-Type"),
            (400, "Invalid request parameter"),
            (400, "Suspended app_id"),
            (400, "Invalid app_id"),
            (404, "Not found:"),
            (405, "Method not allowed.")
        ]

        unexpectedError.forEach { code, message in
            // given
            let data = errorData(code: code, message: message)

            // when
            let result = verifyConvertDispatchedToMainWhen(data: data, statusCode: code)

            // then
            XCTAssertEqual(result, .failure(.unexpected))
        }
    }

    func test_convert_givenFailureResponseWithLimitExceededError_callsCompletionWithlimitExceeded() {
        // given
        let statusCode = 400
        let data = errorData(code: statusCode, message: "Rate limit exceeded")

        // when
        let result = verifyConvertDispatchedToMainWhen(data: data, statusCode: statusCode)

        // then
        XCTAssertEqual(result, .failure(.limitExceeded))
    }

    func test_convert_givenFailureResponseWithTooLongError_callsCompletionWithTooLong() {
        // given
        let statusCode = 413
        let data = errorData(code: statusCode, message: "Request to large")

        // when
        let result = verifyConvertDispatchedToMainWhen(data: data, statusCode: statusCode)

        // then
        XCTAssertEqual(result, .failure(.tooLong))
    }

    func test_convert_givenValidJSON_callsCompletionWithConvertedString() {
        // given
        let expectedConvertedString = "かんじが まざっている ぶんしょう"
        let data = """
        {
            "converted": "\(expectedConvertedString)",
            "output_type": "hiragana",
            "request_id": "labs.goo.ne.jp\\t1575471185\\t0"
        }
        """.data(using: .utf8)!

        // when
        let result = verifyConvertDispatchedToMainWhen(data: data)

        // then
        guard case let .success(convertedString) = result else {
            XCTFail("The result is not a success")
            return
        }

        XCTAssertEqual(convertedString, expectedConvertedString)
    }

    func test_convert_givenInValidJSON_callsCompletionWithUnknown() {
        // given
        let data = "".data(using: .utf8)!

        // when
        let result = verifyConvertDispatchedToMainWhen(data: data)

        // then
        XCTAssertEqual(result, .failure(.unknown))
    }
}

extension GooFuriganaConverterRemoteAPITests {

    func verifyConvertDispatchedToMainWhen(
        data: Data? = nil,
        statusCode: Int = 200,
        error: Error? = nil
    ) -> RemoteAPIResult? {
        session.givenNotMainQueue()

        let response = HTTPURLResponse(
            url: requestURL,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )

        let expectation = self.expectation(
          description: "Completion wasn't called")
        var thread: Thread!
        var receivedResult: RemoteAPIResult?

        let mockTask = sut.convert("") { result in
            thread = Thread.current
            receivedResult = result
            expectation.fulfill()
            } as! MockURLSessionDataTask
        // swiftlint:disable:previous force_cast
        mockTask.completionHandler(data, response, error)

        waitForExpectations(timeout: 0.2) { _ in
            XCTAssert(thread.isMainThread)
        }

        return receivedResult
    }

    func errorData(code: Int, message: String) -> Data {
        """
        {
            "error": {
                "code": \(code),
                "message": "\(message)"
            }
        }
        """.data(using: .utf8)!
    }
}
