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

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        constructHierarchy()
        activateConstraints()
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
