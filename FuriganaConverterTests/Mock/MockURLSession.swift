//
//  MockURLSession.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/03.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class MockURLSession: URLSession {

    private var queue: DispatchQueue?

    override init() {
        // Avoid deprecated warning
    }

    func givenNotMainQueue() {
        queue = DispatchQueue(label: "dev.jierongli.FuriganaConverter")
    }

    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        return MockURLSessionDataTask(
            completionHandler: completionHandler,
            request: request,
            queue: queue
        )
    }
}
