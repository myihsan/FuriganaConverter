//
//  SettingUserInterface.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/08.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

typealias SettingUserInterfaceView = SettingUserInterface & UIView

protocol SettingUserInterface: class {

    var isAutoShowKeyboardEnable: Bool { get set }

    func disableClearHistoryCell()
    func deselectCells()
}
