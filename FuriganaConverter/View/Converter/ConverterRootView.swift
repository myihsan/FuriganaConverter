//
//  ConverterRootView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/05.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit
import SnapKit
import UITextView_Placeholder
import RxKeyboard
import RxSwift
import RxCocoa

class ConverterRootView: NiblessView {

    weak var eventResponder: ConverterEventResponder?

    private let topBar = ConverterTopBar()
    private let inputTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = L10n.typeTheTextToTranslate
        return textView
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    private let resultView = ConvertingResultView()
    private let historyView: ConverterHistoryView
    private let keyboardButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "keyboard")!,
            style: .plain,
            target: nil,
            action: nil
        )
        return buttonItem
    }()
    private let pasteButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: L10n.paste,
            style: .plain,
            target: nil,
            action: nil
        )
        return buttonItem
    }()
    private let clearButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: L10n.clear,
            style: .plain,
            target: nil,
            action: nil
        )
        buttonItem.isEnabled = false
        return buttonItem
    }()
    private let convertButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            title: L10n.convert,
            style: .done,
            target: nil,
            action: nil
        )
        buttonItem.isEnabled = false
        return buttonItem
    }()
    private let toolbar = UIToolbar()

    private let disposeBag = DisposeBag()

    init(historyView: ConverterHistoryView) {
        self.historyView = historyView
        super.init(frame: .zero)

        backgroundColor = .systemBackground
        setupTextView(inputTextView)
        setupTextView(inputTextView.placeholderTextView)
        let resultTextView = resultView.resultTextView
        setupTextView(resultTextView)
        setupTextView(resultTextView.placeholderTextView)

        constructHierarchy()
        activateConstraints()
        updateViewsAlongWithKeyboard()
        updateButtonsAlongWithInputTextView()
        setActionsForControls()
    }

    private func setupTextView(_ textView: UITextView) {
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.showsVerticalScrollIndicator = false
    }

    private func constructHierarchy() {
        addSubview(inputTextView)
        addSubview(resultView)
        addSubview(historyView)
        addSubview(separatorView)
        addSubview(topBar)
        addSubview(toolbar)

        let flexibleSpace =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [keyboardButtonItem, pasteButtonItem, clearButtonItem, flexibleSpace, convertButtonItem]
    }

    private func activateConstraints() {
        activeNavigationBarConstraints()
        activeToolbarConstraints()
        activeSeparatorViewConstrains()
        activeInputTextViewConstraints()
        activeResultTextViewConstraints()
        activeHistoryViewConstraints()
    }

    private func setActionsForControls() {
        topBar.typeSegmentedControl.addTarget(self, action: #selector(selectedTypeChanged), for: .valueChanged)
        keyboardButtonItem.target = self
        keyboardButtonItem.action = #selector(toggleKeyboard)
        pasteButtonItem.target = self
        pasteButtonItem.action = #selector(pasteToInputTextView)
        clearButtonItem.target = self
        clearButtonItem.action = #selector(clearInputText)
        convertButtonItem.target = self
        convertButtonItem.action = #selector(convertInputText)
        resultView.shareButton.addTarget(self, action: #selector(shareResult), for: .touchUpInside)
    }

    private func activeNavigationBarConstraints() {
        topBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }

    private func activeSeparatorViewConstrains() {
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(snp.centerY).offset(-44)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide)
        }
    }

    private func activeInputTextViewConstraints() {
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(separatorView.snp.top)
                 // Ignore if it is not possible when the keyboard is showing
                .priority(.medium)
            make.bottom.lessThanOrEqualTo(toolbar.snp.top)
        }
    }

    private func activeResultTextViewConstraints() {
        resultView.snp.makeConstraints { make in
            make.top.equalTo(separatorView.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(toolbar.snp.top)
                // Ignore if it is not possible when the keyboard is showing
                .priority(.medium)
        }
    }

    private func activeHistoryViewConstraints() {
        historyView.snp.makeConstraints { make in
            make.edges.equalTo(resultView)
        }
    }

    private func activeToolbarConstraints() {
        toolbar.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }

    private func updateViewsAlongWithKeyboard() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self = self else {
                    return
                }
                self.toolbar.snp.updateConstraints { make in
                    let offset: CGFloat
                    if keyboardVisibleHeight == 0 {
                        offset = 0
                    } else {
                        offset = self.safeAreaInsets.bottom - keyboardVisibleHeight
                    }
                    make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(offset)
                }
                self.setNeedsLayout()
                UIView.animate(withDuration: 0) {
                    self.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        inputTextView.rx.didBeginEditing
            .subscribe { _ in
                self.keyboardButtonItem.image = UIImage(systemName: "keyboard.chevron.compact.down")
                self.eventResponder?.inputWillChange()
            }
            .disposed(by: disposeBag)
        inputTextView.rx.didEndEditing
            .subscribe { _ in
                self.keyboardButtonItem.image = UIImage(systemName: "keyboard")
            }
            .disposed(by: disposeBag)
    }

    private func updateButtonsAlongWithInputTextView() {
        inputTextView.rx.didChange
            .subscribe { _ in
                let isNotEmpty = self.inputTextView.text.isEmpty == false
                self.changeButtonsIsEnableTo(isNotEmpty)
            }
            .disposed(by: disposeBag)
    }

    @objc
    private func selectedTypeChanged() {
        let selectedType: ConverterOutputType =
            topBar.typeSegmentedControl.selectedSegmentIndex == 0 ? .hiragana : .katakana
        eventResponder?.didSelect(selectedType)
    }

    @objc
    private func toggleKeyboard() {
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
        } else {
            inputTextView.becomeFirstResponder()
        }
    }

    @objc
    private func pasteToInputTextView() {
        let selectedRange = inputTextView.selectedRange
        let text = (inputTextView.text ?? "") as NSString
        let textToPaste = UIPasteboard.general.string ?? ""
        inputTextView.text = text.replacingCharacters(in: selectedRange, with: textToPaste)
        if inputTextView.isFirstResponder {
            let newSelectedRange = NSRange(location: selectedRange.location + textToPaste.count, length: 0)
            inputTextView.selectedRange = newSelectedRange
        }
    }

    @objc
    private func clearInputText() {
        eventResponder?.inputWillChange()
        inputTextView.text = nil
        changeButtonsIsEnableTo(false)
    }

    @objc
    private func convertInputText() {
        eventResponder?.convert(inputTextView.text)
        inputTextView.resignFirstResponder()
    }

    @objc
    private func shareResult() {
        eventResponder?.share(resultView.resultTextView.text)
    }

    private func changeButtonsIsEnableTo(_ isEnable: Bool) {
        clearButtonItem.isEnabled = isEnable
        convertButtonItem.isEnabled = isEnable
    }
}

extension ConverterRootView: UINavigationBarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension ConverterRootView: ConverterUserInterface {

    var selectedType: ConverterOutputType {
        get {
            topBar.typeSegmentedControl.selectedSegmentIndex == 0 ? .hiragana : .katakana
        }
        set {
            topBar.typeSegmentedControl.selectedSegmentIndex = newValue == .hiragana ? 0 : 1
        }
    }

    var result: String {
        resultView.resultTextView.text
    }

    func changeState(_ state: ConverterUserInterfaceState) {
        let animateions: () -> Void
        switch state {
        case .history:
            animateions = {
                self.historyView.isHidden = false
                self.resultView.isHidden = true
            }
        case let .result(originalString, resultViewState):
            inputTextView.resignFirstResponder()
            changeButtonsIsEnableTo(true)
            if let originalString = originalString {
                inputTextView.text = originalString
            }
            resultView.changeState(resultViewState)
            animateions = {
                self.historyView.isHidden = true
                self.resultView.isHidden = false
            }
        }
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: animateions)
    }
}
