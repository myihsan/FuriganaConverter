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
    private let remoteAPI: FuriganaConverterRemoteAPI

    init(userInterface: ConverterUserInterfaceView, remoteAPI: FuriganaConverterRemoteAPI) {
        self.userInterface = userInterface
        self.remoteAPI = remoteAPI
        super.init()
    }

    override func loadView() {
        view = userInterface
    }
}

extension ConvertorViewController: ConverterEventResponder {

    func convert(_ japaneseString: String) {
        remoteAPI.convert(japaneseString) { result in
            switch result {
            case let .success(convertedString):
                self.userInterface.setResult(convertedString)
            case let .failure(error):
                error
            }
        }
    }
}
