//
//  ConverterEventResponder.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

protocol ConverterEventResponder: class {

    func inputWillChange()
    func convert(_ japaneseString: String)
    func share(_ convertedString: String)
    func didSelect(_ type: ConverterOutputType)
    func didTapSettingButton()
}
