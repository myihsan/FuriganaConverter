//
//  RemoteAPIError.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

enum RemoteAPIError: Error {

    case limitExceeded
    case tooLong
    case unknown
    case unexpected
}
