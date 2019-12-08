//
//  ConvertorViewController.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import RxSwift
import CoreData

class ConverterViewController: NiblessViewController {

    private static let selectedTypeRawValueUserDefaultsKey = "SelectedType"

    private let userInterface: ConverterUserInterfaceView
    private let remoteAPI: FuriganaConverterRemoteAPI

    private let convertSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private var convertTask: URLSessionDataTask?

    private let coreDataStack: CoreDataStack
    private let historyHolder: HistoryHolder

    init(
        userInterface: ConverterUserInterfaceView,
        remoteAPI: FuriganaConverterRemoteAPI,
        coreDataStack: CoreDataStack,
        historyHolder: HistoryHolder
    ) {
        self.userInterface = userInterface
        self.remoteAPI = remoteAPI
        self.coreDataStack = coreDataStack
        self.historyHolder = historyHolder
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

extension ConverterViewController: ConverterEventResponder {

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
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .subscribe(onNext: { japaneseString in
                if let convertedString = self.getConvertedStringFromHistory(japaneseString: japaneseString) {
                    self.setResult(convertedString: convertedString)
                    return
                }
                if let convertTask = self.convertTask {
                    convertTask.cancel()
                }
                self.convertTask = self.remoteAPI.convert(japaneseString) { [weak self] result in
                    guard let self = self else {
                        return
                    }
                    switch result {
                    case let .success(convertedString):
                        self.saveHistory(originalString: japaneseString, convertedString: convertedString)
                        self.setResult(convertedString: convertedString)
                    case let .failure(error):
                        error
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    private func setResult(convertedString: String) {
        var convertedString = convertedString
        if userInterface.selectedType == .katakana {
            convertedString = convertedString
                .applyingTransform(.hiraganaToKatakana, reverse: false) ?? convertedString
        }
        self.userInterface.result = convertedString
    }

    private func getConvertedStringFromHistory(japaneseString: String) -> String? {
        historyHolder.histories
            .first { $0.originalString == japaneseString }?
            .convertedString
    }

    private func saveHistory(originalString: String, convertedString: String) {
        let history = History(context: self.coreDataStack.managedContext)
        history.originalString = originalString
        history.convertedString = convertedString
        history.timestamp = Date()
        coreDataStack.saveContext()
    }
}

extension ConverterViewController: ConverterHistoryEventResponder {

    func didSelect(_ history: History) {
        
    }

    func delete(_ history: History) {
        coreDataStack.managedContext.delete(history)
        coreDataStack.saveContext()
    }
}
