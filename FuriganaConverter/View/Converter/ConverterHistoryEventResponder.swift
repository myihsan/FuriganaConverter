//
//  ConverterHistoryEventResponder.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

protocol ConverterHistoryEventResponder: class {

    func didSelect(_ history: History)
    func delete(_ history: History)
}
