//
//  ConvertingResultView.swift
//  FuriganaConverter
//
//  Created by Jierong Li on 2019/12/07.
//  Copyright © 2019 Jierong Li. All rights reserved.
//

import UIKit

class ConvertingResultView: NiblessView {

    let shareButton: UIButton = {
        let button = UIButton()
        let shareImage = UIImage(systemName: "square.and.arrow.up")!
        button.setImage(shareImage, for: .normal)
        return button
    }()
    private let copyButton: UIButton = {
        let button = UIButton()
        let shareImage = UIImage(systemName: "doc.on.doc")!
        button.setImage(shareImage, for: .normal)
        return button
    }()
    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()
    let resultTextView: UITextView = {
        let textView = UITextView()
        textView.placeholder = L10n.convertingResult
        textView.isEditable = false
        return textView
    }()

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)

        backgroundColor = .systemBackground

        constructHierarchy()
        activateConstraints()

        copyButton.addTarget(self, action: #selector(copyResult), for: .touchUpInside)
    }

    private func constructHierarchy() {
        addSubview(resultTextView)
        addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(shareButton)
        buttonsStackView.addArrangedSubview(copyButton)
    }

    private func activateConstraints() {
        activateButtonsStackViewConstraints()
        activateResultTextViewConstraints()
    }

    private func activateButtonsStackViewConstraints() {
        buttonsStackView.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(44)
        }
    }

    private func activateResultTextViewConstraints() {
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(buttonsStackView.snp.bottom)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self)
        }
    }

    @objc
    private func copyResult() {
        UIPasteboard.general.string = resultTextView.text
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ConvertingResultViewRepresentable: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        ConvertingResultView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ConvertingResultView_Previews: PreviewProvider {

    static var previews: some View {
        ConvertingResultViewRepresentable()
            .previewLayout(.fixed(width: 400, height: 300))
            .accentColor(.green)
    }
}
#endif
