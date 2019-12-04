//
//  FuriganaConverterRemoteAPI.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

typealias RemoteAPIResult = Result<String, RemoteAPIError>

protocol FuriganaConverterRemoteAPI {

    func convert(
        _ japaneseString: String,
        completionHandler: @escaping (RemoteAPIResult) -> Void
    )
}
