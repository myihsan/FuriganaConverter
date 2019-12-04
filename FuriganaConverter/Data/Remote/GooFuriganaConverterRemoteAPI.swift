//
//  GooFuriganaConverterRemoteAPI.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class GooFuriganaConverterRemoteAPI: FuriganaConverterRemoteAPI {

    private let requestURL = URL(string: "https://labs.goo.ne.jp/api/hiragana")!
    let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (Result<String, RemoteAPIError>) -> Void
    ) -> URLSessionDataTask {
        let request = URLRequest(url: URL(string: "Wrong", relativeTo: requestURL)!)
        return session.dataTask(with: request) { _, _, _ in }
    }
}
