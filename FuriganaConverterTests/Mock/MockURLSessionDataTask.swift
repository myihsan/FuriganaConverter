//
//  MockURLSessionDataTask.swift
//  FuriganaConverterTests
//
//  Created by Jierong Li on 2019/12/03.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {

    let completionHandler: (Data?, URLResponse?, Error?) -> Void
    let request: URLRequest

    init(
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
        request: URLRequest
    ) {
        self.completionHandler = completionHandler
        self.request = request
    }

    override func resume() {
        // Do nothing to avoid actually starting this task
    }
}
