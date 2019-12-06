//
//  ConvertorViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class ConvertorViewController: NiblessViewController {

    private let userInterface: ConverterUserInterfaceView

    init(userInterface: ConverterUserInterfaceView) {
        self.userInterface = userInterface
        super.init()
    }

    override func loadView() {
        view = userInterface
    }
}

extension ConvertorViewController: ConverterEventResponder {

    func convert(_ japaneseString: String) {}
}
