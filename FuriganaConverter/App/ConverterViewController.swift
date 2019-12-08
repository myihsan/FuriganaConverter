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

    private let userInterface: ConverterUserInterfaceView
    private let remoteAPI: FuriganaConverterRemoteAPI
    private let coreDataStack: CoreDataStack
    private let historyHolder: HistoryHolder
    private let makeSettingViewController: () -> UIViewController

    private let convertSubject = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    private var convertTask: URLSessionDataTask?

    init(
        userInterface: ConverterUserInterfaceView,
        remoteAPI: FuriganaConverterRemoteAPI,
        coreDataStack: CoreDataStack,
        historyHolder: HistoryHolder,
        makeSettingViewController: @escaping () -> UIViewController
    ) {
        self.userInterface = userInterface
        self.remoteAPI = remoteAPI
        self.coreDataStack = coreDataStack
        self.historyHolder = historyHolder
        self.makeSettingViewController = makeSettingViewController
        super.init()

        recoverSelectedType()
        subscribeToConverterEvent()
    }

    override func loadView() {
        view = userInterface
    }

    private func recoverSelectedType() {
        if let selectedTypeRawValue = UserDefaults.standard.string(forKey: .selectedTypeRawValueUserDefaultsKey),
            let selectedType = ConverterOutputType(rawValue: selectedTypeRawValue) {
            userInterface.selectedType = selectedType
        } else {
            userInterface.selectedType = .hiragana
        }
    }
}

extension ConverterViewController: ConverterEventResponder {

    func inputWillChange() {
        convertTask?.cancel()
        userInterface.state = .history
    }

    func convert(_ japaneseString: String) {
        convertSubject.onNext(japaneseString)
    }

    func share(_ convertedString: String) {
        let activityItems = [convertedString]
        let activityViewContriller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewContriller, animated: true)
    }

    func didSelect(_ type: ConverterOutputType) {
        UserDefaults.standard.set(type.rawValue, forKey: .selectedTypeRawValueUserDefaultsKey)
        let reverse = type == .hiragana
        if case let .result(_, resultViewState) = userInterface.state,
            case let .result(currentResult) = resultViewState {
            let convertedString = currentResult
                .applyingTransform(.hiraganaToKatakana, reverse: reverse) ?? currentResult
            setResult(convertedString: convertedString)
        }
    }

    func didTapSettingButton() {
        let settingViewController = makeSettingViewController()
        present(settingViewController, animated: true)
    }

    private func subscribeToConverterEvent() {
        convertSubject
            // Prevent repeated taps
            .throttle(.milliseconds(300), latest: false, scheduler: MainScheduler.instance)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .subscribe(onNext: { japaneseString in
                if let convertedString = self.getConvertedStringFromHistory(japaneseString: japaneseString) {
                    self.setHiraganaResult(convertedString: convertedString)
                    return
                }
                if let convertTask = self.convertTask {
                    convertTask.cancel()
                }
                self.userInterface.state = .result(resultViewState: .loading)
                self.callRemoteAPI(japaneseString: japaneseString)
            })
            .disposed(by: disposeBag)
    }

    private func callRemoteAPI(japaneseString: String) {
        self.convertTask = self.remoteAPI.convert(japaneseString) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(convertedString):
                self.saveHistory(originalString: japaneseString, convertedString: convertedString)
                self.setHiraganaResult(convertedString: convertedString)
            case let .failure(error):
                self.userInterface.state = .history
                let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                switch error {
                case .limitExceeded:
                    alertViewController.title = L10n.rateLimitExceeded
                    alertViewController.message = L10n.pleaseWaitUntilTomorrow
                    alertViewController.addOKAction()
                case .tooLong:
                    alertViewController.title = L10n.textTooLong
                    alertViewController.message = L10n.pleaseTryAgainWithAShorterText
                    alertViewController.addOKAction()
                case .unknown,
                     .unexpected:
                    alertViewController.title = L10n.convertingFailed
                    alertViewController.addCancelAction()
                    let retryAction = UIAlertAction(title: L10n.retry, style: .default) { _ in
                        self.callRemoteAPI(japaneseString: japaneseString)
                    }
                    alertViewController.addAction(retryAction)
                }
                self.present(alertViewController, animated: true)
            }
        }
    }

    private func setHiraganaResult(originalString: String? = nil, convertedString: String) {
        var convertedString = convertedString
        if userInterface.selectedType == .katakana {
            convertedString = convertedString
                .applyingTransform(.hiraganaToKatakana, reverse: false) ?? convertedString
        }
        setResult(originalString: originalString, convertedString: convertedString)
    }

    private func setResult(originalString: String? = nil, convertedString: String) {
        userInterface.state = .result(originalString: originalString, resultViewState: .result(convertedString))
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
        let originalString = history.originalString
        let convertedString = history.convertedString
        setHiraganaResult(originalString: originalString, convertedString: convertedString)
    }

    func delete(_ history: History) {
        coreDataStack.managedContext.delete(history)
        coreDataStack.saveContext()
    }
}
