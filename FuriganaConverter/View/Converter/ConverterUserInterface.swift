//
//  ConverterUserInterface.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

typealias ConverterUserInterfaceView = ConverterUserInterface & UIView

protocol ConverterUserInterface {

    func setResult(_ result: String)
}
