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
        let privateInfosPath = Bundle.main.path(forResource: "PrivateInfo", ofType: "plist")!
        let privateInfos = NSDictionary(contentsOfFile: privateInfosPath)!
        // Invalid app_id is better then crash
        // if there is a proper alert like "Please contact the developer.".
        appID = privateInfos["AppID"] as? String ?? ""
    }

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (Result<String, RemoteAPIError>) -> Void
    ) -> URLSessionDataTask {
        var request = URLRequest(url: requestURL)
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
            defer {
                completionHandler(result)
            }

            guard let response = response as? HTTPURLResponse,
                error == nil else {
                return
            }

            let statusCode = response.statusCode
            guard statusCode == 200 else {

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

                if  Self.unexpectedMessages.contains(errorResponse.error.message) {
                    result = .failure(.unexpected)
                    return
                }
                return
            }
        }
        task.resume()
        return task
    }
}
