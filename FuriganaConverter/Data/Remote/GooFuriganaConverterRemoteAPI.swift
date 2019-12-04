//
//  GooFuriganaConverterRemoteAPI.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import Foundation

class GooFuriganaConverterRemoteAPI: FuriganaConverterRemoteAPI {

    let requestURL = URL(string: "https://example.com/")!

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (Result<String, RemoteAPIError>) -> Void
    ) {}
}
