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
        return session.dataTask(with: request) { _, _, _ in }
    }
}
