//
//  GooFuriganaConverterRemoteAPI.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class GooFuriganaConverterRemoteAPI: FuriganaConverterRemoteAPI {

    let session: URLSession

    private let requestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!
    private let appID: String
    private static let unexpectedStatusCodes = [404, 405]
    private static let limitExceededMessage = "Rate limit exceeded"
    private static let tooLongMessage = "Request to large"
    private static let unexpectedMessages = [
        "Content-Type is empty",
        "Invalid JSON",
        "Invalid Content-Type",
        "Invalid request parameter",
        "Suspended app_id",
        "Invalid app_id",
        "Rate limit exceeded"
    ]

    init(session: URLSession) {
        self.session = session
        appID = PrivateInfoPlist.appID
    }

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (Result<String, RemoteAPIError>) -> Void
    ) -> URLSessionDataTask {
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let httpBodyJSONObject = [
            "app_id": appID,
            "sentence": japaneseString,
            "output_type": "hiragana"
        ]
        // Never failed since httpBodyJSONObject is a [String: String]
        // swiftlint:disable:next force_try
        request.httpBody = try!  JSONSerialization.data(withJSONObject: httpBodyJSONObject)
        let task = session.dataTask(with: request) { data, response, error in
            var result = RemoteAPIResult.failure(.unknown)
            var isCancelled = false
            defer {
                if !isCancelled {
                    DispatchQueue.main.async {
                        completionHandler(result)
                    }
                }
            }

            guard let response = response as? HTTPURLResponse,
                error == nil else {
                    if let error = error as NSError?,
                        error.domain == NSURLErrorDomain,
                        error.code == NSURLErrorCancelled {
                            isCancelled = true
                    }
                    return
            }

            let statusCode = response.statusCode
            guard statusCode == 200 else {
                self.handleFailure(statusCode: statusCode, data: data, result: &result)
                return
            }

            guard let data = data else {
                // Success but no response body
                return
            }

            let decoder = JSONDecoder()
            guard let gooFuriganaConverterResponse = try? decoder
                .decode(GooFuriganaConverterResponse.self, from: data) else {
                return
            }

            result = .success(gooFuriganaConverterResponse.converted)
        }
        task.resume()
        return task
    }

    private func handleFailure(statusCode: Int, data: Data?, result: inout RemoteAPIResult) {
        if Self.unexpectedStatusCodes.contains(statusCode) {
            result = .failure(.unexpected)
            return
        }

        guard let data = data else {
            return
        }

        let decoder = JSONDecoder()
        guard let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) else {
            return
        }

        let message = errorResponse.error.message
        if message == Self.limitExceededMessage {
            result = .failure(.limitExceeded)
            return
        }

        if message == Self.tooLongMessage {
            result = .failure(.tooLong)
            return
        }

        if  Self.unexpectedMessages.contains(message) {
            result = .failure(.unexpected)
            return
        }
    }
}
