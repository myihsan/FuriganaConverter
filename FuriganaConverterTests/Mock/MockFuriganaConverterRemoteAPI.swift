//
//  MockFuriganaConverterRemoteAPI.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

@testable import FuriganaConverter
import Foundation

class MockFuriganaConverterRemoteAPI: FuriganaConverterRemoteAPI {

    var result = RemoteAPIResult.failure(.unknown)

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (RemoteAPIResult) -> Void
    ) -> URLSessionDataTask {
        completionHandler(result)
        return MockURLSessionDataTask()
    }

    private class MockURLSessionDataTask: URLSessionDataTask {

        override init() {
            // Avoid deprecated warning
        }
    }
}
