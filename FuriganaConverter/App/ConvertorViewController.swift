//
//  ConvertorViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import RxSwift

class ConvertorViewController: NiblessViewController {

    private static let selectedTypeRawValueUserDefaultsKey = "SelectedType"

    private let userInterface: ConverterUserInterfaceView
    private let remoteAPI: FuriganaConverterRemoteAPI

    private let convertSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private var convertTask: URLSessionDataTask?

    private let coreDataStack: CoreDataStack

    init(
        userInterface: ConverterUserInterfaceView,
        remoteAPI: FuriganaConverterRemoteAPI,
        coreDataStack: CoreDataStack
    ) {
        self.userInterface = userInterface
        self.remoteAPI = remoteAPI
        self.coreDataStack = coreDataStack
        super.init()

        recoverSelectedType()
        subscribeToConverterEvent()
    }

    override func loadView() {
        view = userInterface
    }

    private func recoverSelectedType() {
        if let selectedTypeRawValue = UserDefaults.standard.string(forKey: Self.selectedTypeRawValueUserDefaultsKey),
            let selectedType = ConverterOutputType(rawValue: selectedTypeRawValue) {
            userInterface.selectedType = selectedType
        } else {
            userInterface.selectedType = .hiragana
        }
    }
}

extension ConvertorViewController: ConverterEventResponder {

    func convert(_ japaneseString: String) {
        convertSubject.onNext(japaneseString)
    }

    func share(_ convertedString: String) {
        let activityItems = [convertedString]
        let activityViewContriller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewContriller, animated: true)
    }

    func didSelect(_ type: ConverterOutputType) {
        UserDefaults.standard.set(type.rawValue, forKey: Self.selectedTypeRawValueUserDefaultsKey)
        let reverse = type == .hiragana
        let currentResult = userInterface.result
        userInterface.result = currentResult
                .applyingTransform(.hiraganaToKatakana, reverse: reverse) ?? currentResult

    }

    private func subscribeToConverterEvent() {
        convertSubject
            // Prevent repeated taps
            .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { japaneseString in
                if let convertTask = self.convertTask {
                    convertTask.cancel()
                }
                self.convertTask = self.remoteAPI.convert(japaneseString) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case var .success(convertedString):
                        if self.userInterface.selectedType == .katakana {
                            convertedString = convertedString
                                .applyingTransform(.hiraganaToKatakana, reverse: false) ?? convertedString
                        }
                        self.userInterface.result = convertedString
                    case let .failure(error):
                        error
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}
