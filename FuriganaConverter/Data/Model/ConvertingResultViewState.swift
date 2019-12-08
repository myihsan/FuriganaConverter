//
//  ConvertingResultViewState.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

enum ConvertingResultViewState: Equatable {

    case loading
    case result(_ convertedString: String)
}
