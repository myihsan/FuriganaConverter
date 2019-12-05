//
//  ErrorResponse.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

struct ErrorResponse: Decodable {

    struct Error: Codable {
        public let message: String
    }

    let error: Error
}
