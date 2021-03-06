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
    var calledResume = false

    init(
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void,
        request: URLRequest,
        queue: DispatchQueue?
    ) {
        if let queue = queue {
            self.completionHandler = { data, response, error in
                queue.async {
                    completionHandler(data, response, error)
                }
            }
        } else {
            self.completionHandler = completionHandler
        }
        self.request = request
    }

    override func resume() {
        calledResume = true
    }
}
