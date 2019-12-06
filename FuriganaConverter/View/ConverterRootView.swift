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

    private let navigationBar = UINavigationBar()
    private let inputTextView: UITextView = {
        let textView = UITextView()
        let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.title2)
        let placeholderTextView: UITextView! = textView.placeholderTextView
        textView.font = font
        placeholderTextView.font = font
        let contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.textContainerInset = contentInset
        placeholderTextView.textContainerInset = contentInset
        textView.placeholder = L10n.typeTheTextToTranslate
        textView.showsVerticalScrollIndicator = false
        return textView
    }()
    private let keyboardButtonItem: UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(
            image: UIImage(systemName: "keyboard")!,
            style: .plain,
            target: nil,
            action: nil
        )
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

        constructHierarchy()
        activateConstraints()
        updateViewsAlongWithKeyboard()

        keyboardButtonItem.action = #selector(toggleKeyboard)
    }

    private func constructHierarchy() {
        addSubview(inputTextView)
        addSubview(navigationBar)
        addSubview(toolbar)

        let flexibleSpace =
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [keyboardButtonItem, flexibleSpace, convertButtonItem]
    }

    private func activateConstraints() {
        activeNavigationBarConstraints()
        activeToolbarConstraints()
        activeInputTextViewConstraints()
    }

    private func activeNavigationBarConstraints() {
        navigationBar.delegate = self
        navigationBar.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }

    private func activeInputTextViewConstraints() {
        inputTextView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.equalTo(safeAreaLayoutGuide)
            make.trailing.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(snp.centerY)
        }
    }

    private func activeToolbarConstraints() {
        toolbar.snp.makeConstraints { make in
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
    }

    func updateViewsAlongWithKeyboard() {
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

    @objc
    private func toggleKeyboard() {
        if inputTextView.isFirstResponder {
            inputTextView.resignFirstResponder()
        } else {
            inputTextView.becomeFirstResponder()
        }
    }
}

extension ConverterRootView: UINavigationBarDelegate {

    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
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
