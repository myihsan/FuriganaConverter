//
//  MockURLSession.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/03.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class MockURLSession: URLSession {

    override init() {
        // Avoid deprecated warning
    }

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask(
            completionHandler: completionHandler,
            request: request
        )
    }
}
