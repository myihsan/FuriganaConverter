//
//  ConverterUserInterfaceState.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

enum ConverterUserInterfaceState: Equatable {

    case history
    case result(originalString: String? = nil, resultViewState: ConvertingResultViewState)
}
