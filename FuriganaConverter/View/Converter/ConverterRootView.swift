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

    private let navigationBar = UINavigationBar()
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
    private let keyboardButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "keyboard")!,
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

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

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

        keyboardButtonItem.action = #selector(toggleKeyboard)
        clearButtonItem.action = #selector(clearInputText)
        convertButtonItem.action = #selector(convertInputText)
        resultView.shareButton.addTarget(self, action: #selector(shareResult), for: .touchUpInside)
    }

    private func setupTextView(_ textView: UITextView) {
        textView.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.showsVerticalScrollIndicator = false
    }

    private func constructHierarchy() {
        addSubview(inputTextView)
        addSubview(resultView)
        addSubview(separatorView)
        addSubview(navigationBar)
        addSubview(toolbar)

        let flexibleSpace =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 16
        toolbar.items = [keyboardButtonItem, fixedSpace, clearButtonItem, flexibleSpace, convertButtonItem]
    }

    private func activateConstraints() {
        activeNavigationBarConstraints()
        activeToolbarConstraints()
        activeSeparatorViewConstrains()
        activeInputTextViewConstraints()
        activeResultTextViewConstraints()
    }

    private func activeNavigationBarConstraints() {
        navigationBar.delegate = self
        navigationBar.snp.makeConstraints { make in
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
            make.top.equalTo(navigationBar.snp.bottom)
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
                self.clearButtonItem.isEnabled = isNotEmpty
                self.convertButtonItem.isEnabled = isNotEmpty
            }
            .disposed(by: disposeBag)
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
    private func clearInputText() {
        inputTextView.text = nil
        self.clearButtonItem.isEnabled = false
        self.convertButtonItem.isEnabled = false
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
}

extension ConverterRootView: UINavigationBarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension ConverterRootView: ConverterUserInterface {

    func setResult(_ result: String) {
        resultView.resultTextView.text = result
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ConverterRootViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        ConverterRootView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

let deviceNames: [String] = [
    "iPhone 11 Pro Max",
    "iPhone SE"
]

struct ConverterRootView_Previews: PreviewProvider {

    static var previews: some View {
        ForEach(deviceNames, id: \.self) { deviceName in
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                ConverterRootViewRepresentable()
                    .accentColor(.green)
                    .environment(\.colorScheme, colorScheme)
                    .previewDevice(PreviewDevice(rawValue: deviceName))
                    .previewDisplayName("\(deviceName) (\(colorScheme))")
            }
        }
    }
}
#endif
